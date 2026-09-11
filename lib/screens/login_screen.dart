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
                child: const RiveAnimation.asset('assets/login_bear.riv'),
              ),
              //para separar espacios
              SizedBox(height: 10),
              //Campo de texto para Email
              TextField(
                //para mostrar el tipo de teclado
                keyboardType: TextInputType.emailAddress,
                decoration:InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  )
                )
              ),
              SizedBox(height: 10),
              //Campo de texto para contraseña
              TextField(
                obscureText: _obscure,
                //para mostrar el tipo de teclado
                keyboardType: TextInputType.visiblePassword,
                decoration:InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    //if ternario
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off
                    ),
                    onPressed: (){
                      //Refrescar el icono de la contraseña
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  )
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}