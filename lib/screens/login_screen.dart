// ignore_for_file: unused_field

import 'package:flutter/material.dart';

import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //control para mostrar u ocultar la contraseña
  bool _obscure = true;

  //1.1 Crear el cerebro de la animacion
  StateMachineController? _controller;

  //SMI: State Machine Input / entrada de maquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

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
                  onInit: (artboart) {
                    _controller = StateMachineController.fromArtboard(
                      artboart,
                      'Login Machine',
                    );

                    //1.3 Verificar
                    if (_controller == null) return;

                    //agrega controlador a escenario
                    artboart.addController(_controller!);

                    //vinculamos variables
                    _isChecking =
                        _controller!.findSMI('isChecking');
                    _isHandsUp =
                        _controller!.findSMI('isHandsUp');
                    _trigSuccess =
                        _controller!.findSMI('trigSuccess');
                    _trigFail =
                        _controller!.findSMI('trigFail');

                    _isChecking?.change(true);
                    _isHandsUp?.change(false);
                  },
                ),
              ),

              //para separar espacios
              SizedBox(height: 10),

              //Campo de texto para Email
              TextField(
                //para mostrar el tipo de teclado
                keyboardType: TextInputType.emailAddress,
                onTap: () {
                  _isChecking?.change(true);
                  _isHandsUp?.change(false);
                },
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 10),

              //Campo de texto para contraseña
              TextField(
                onTap: () {
                  _isChecking?.change(false);
                  _isHandsUp?.change(true);
                },
                onChanged: (value) {
                  if (_isChecking != null) {
                    //No tapes los ojos al ver email
                    _isChecking!.change(false);
                  }

                  //Si isChecking es nulo
                  if (_isHandsUp == null) return;

                  //Activar el modo chismoso
                  _isHandsUp!.change(true);
                },
                obscureText: _obscure,
                //para mostrar el tipo de teclado
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    //if ternario
                    icon: Icon(
                      _obscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      //Refrescar el icono de la contraseña
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    //para redondear los bordes
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
}