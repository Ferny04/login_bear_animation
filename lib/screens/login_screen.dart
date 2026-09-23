// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Control para mostrar u ocultar la contraseña
  bool _obscure = true;

  // 1.1 Crear el cerebro de la animación
  StateMachineController? _controller;

  // SMI: State Machine Input / entrada de máquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  // 2.1 Crear las variables para FocusNode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // 2.2 Listeners (oyentes/chismosos)
  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        // Verificar que no sea nulo
        if (_isHandsUp != null) {
          // Manos abajo en el email
          _isHandsUp!.change(false);
        }
      }
    });

    _passwordFocusNode.addListener(() {
      // Manos arriba en password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/login_bear.riv',
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );

                    // 1.3 Verificar
                    if (_controller == null) return;

                    // Agregar controlador al escenario
                    artboard.addController(_controller!);

                    // Vinculamos variables
                    _isChecking =
                        _controller!.findSMI('isChecking') as SMIBool?;

                    _isHandsUp =
                        _controller!.findSMI('isHandsUp') as SMIBool?;

                    _trigSuccess =
                        _controller!.findSMI('trigSuccess') as SMITrigger?;

                    _trigFail =
                        _controller!.findSMI('trigFail') as SMITrigger?;

                    _isChecking?.change(true);
                    _isHandsUp?.change(false);
                  },
                ),
              ),

              // Para separar espacios
              const SizedBox(height: 10),

              // Campo de texto para Email
              TextField(
                // Asignar FocusNode al email
                focusNode: _emailFocusNode,

                // Para mostrar el tipo de teclado
                keyboardType: TextInputType.emailAddress,

                onTap: () {
                  _isChecking?.change(true);
                  _isHandsUp?.change(false);
                },

                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    // Para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Campo de texto para contraseña
              TextField(
                // 2.3 Asignar foco al campo de texto
                focusNode: _passwordFocusNode,

                onTap: () {
                  _isChecking?.change(false);
                  _isHandsUp?.change(true);
                },

                onChanged: (value) {
                  // Si isHandsUp es nulo
                  if (_isHandsUp == null) return;

                  // Activar el modo chismoso
                  _isHandsUp!.change(true);
                },

                obscureText: _obscure,

                // Para mostrar el tipo de teclado
                keyboardType: TextInputType.visiblePassword,

                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(
                    // If ternario
                    icon: Icon(
                      _obscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {
                      // Refrescar el icono de la contraseña
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),

                  border: OutlineInputBorder(
                    // Para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    // 2.4 Liberar espacio en memoria
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}