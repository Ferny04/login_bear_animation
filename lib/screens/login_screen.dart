import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; // 3.1 Importar el timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  // 1.1 crear el cerebro de la anmación
  StateMachineController? _controller;
  // SMI: State Machine Input / Entrada de máquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  // 3.2 variable del recorrido de la mirada
  SMINumber? _numLook;

  // 3.3 Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;

  // 2.1 crear las variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //4.1 Controles que manipulan lo que el usuario escribe
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  //Errores para mostrarlo en la UI
  String? emailError;
  String? passwordError;

  //4.2 validadores
  bool isValidEmail(String email) {
    // Validación simple de correo electrónico
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',);
    return re.hasMatch(password);
  }

  //4.4 dar accion al boton
  void _onLogin(){
    //4.5 de lo que escribio el usuario, quitar espacios en blanco
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text; 

    //4.6 Evaluar errores
    final eError = isValidEmail(email) ? null : 'Invalid email';
    final pError = isValidPassword(password) ? null : 'Invalid password';

    //4.7 Avisar que hubo cambios
    setState(() {
      emailError = eError;
      passwordError = pError;
    });

    //4.8 Cerrar el tecladdo y bajar las manos del oso
    FocusScope.of(context).unfocus(); //quita el foco
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //4.9 Activar triggers
    if(eError == null && pError == null){
      _trigSuccess?.fire();
       } else {
      _trigFail?.fire();
       }
  }

  // 2.2 Listeners (oyentes/chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        // verificar que no sea nulo
        if (_isHandsUp != null) {
          // manos abajo en el email
          _isHandsUp?.change(false);
          // 3.4 Mirada neutra inicial
          _numLook?.value = 0.0;
        }
      } else {
        _isChecking?.change(false);
      }
    });
    
    _passwordFocus.addListener(() {
      // manos arriba en password dependiendo de si está oculta
      _isHandsUp?.change(_passwordFocus.hasFocus && _obscure);
      if (_passwordFocus.hasFocus) {
        _isChecking?.change(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    // EL ERROR ESTABA AQUÍ: login_bear (guion bajo), no login-bear
                    'assets/login_bear.riv', 
                    stateMachines: const ['Login Machine'],
                    // 1.2 vincular animación
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );
        
                      // 1.3 verificar que inicio bien
                      if (_controller == null) return;
                      // Agrega controlador al escenario
                      artboard.addController(_controller!);
                      
                      // vinculamos variables
                      _isChecking = _controller!.findSMI('isChecking') as SMIBool?;
                      _isHandsUp = _controller!.findSMI('isHandsUp') as SMIBool?;
                      _trigSuccess = _controller!.findSMI('trigSuccess') as SMITrigger?;
                      _trigFail = _controller!.findSMI('trigFail') as SMITrigger?;
                      
                      // 3.5 vincular numLook (con respaldo por si el archivo usa mayúscula)
                      _numLook = (_controller!.findSMI('numLook') ?? _controller!.findSMI('Look')) as SMINumber?;
                    },
                  ),
                ),
                
                // para separar espacio
                const SizedBox(height: 10),
                
                TextField(
                  //4.10 Enlazar controller
                  controller: emailCtrl,
                  // 2.3 asignar foco al campo de texto
                  focusNode: _emailFocus,
                  
                  onTap: () {
                    _isChecking?.change(true);
                    _isHandsUp?.change(false);
                  },
        
                  onChanged: (value) {
                    // si checking es nulo
                    if (_isChecking == null) return;
                    // activa el modo chismoso
                    _isChecking!.change(true);
                    
                    // 3.6 Implementar numLook
                    // Ajustes de límites del 0 a 100
                    // Bajamos a 30.0 para que el movimiento de los ojos sea notorio
                    final look = (value.length / 30.0 * 100.0).clamp(0.0, 100.0);
                    // Clamp es el rango (abrazadera)
                    _numLook?.value = look;
        
                    // 3.7 Debounce: si vuelve a teclear, reinicia el contador
                    // Cancelar cualquier timer existente
                    _typingDebounce?.cancel();
                    // crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 2), () {
                      // si se cierra la pantalla, quita el contador
                      if (!mounted) return;
                      // Mirada neutra
                      _isChecking?.change(false);
                    });
                  },
                  
                  // para mostrar el tipo de teclado
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // campo de texto para contraseña
                TextField(
                  //4.10 enlazar controller
                  controller: passwordCtrl,
                  // 2.3 asignar foco al campo de texto
                  focusNode: _passwordFocus,
                  
                  onTap: () {
                    _isChecking?.change(false);
                    _isHandsUp?.change(_obscure);
                  },
        
                  onChanged: (value) {
                    // si isHandsUp es nulo
                    if (_isHandsUp == null) return;
                    // activa las manos arriba si el texto está oculto
                    _isHandsUp!.change(_obscure);
                  },
        
                  obscureText: _obscure,
                  // Para mostrar el tipo de teclado
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    errorText: passwordError,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // refrescar el icono
                        setState(() {
                          _obscure = !_obscure;
                        });
                        
                        // Actualizar animación: destapar los ojos si mostramos la contraseña
                        if (_passwordFocus.hasFocus) {
                          _isHandsUp?.change(_obscure);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      // para redondear bordes
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              //4.12 Texto olvide la contraseña
              SizedBox(width: size.width, child: const Text('Forgot Password?', //alinear a la derecha 
              textAlign: TextAlign.right, style: TextStyle(decoration: TextDecoration.underline)
              )
              ),
              const SizedBox(height: 10),
              //4.13 Boton de login
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _onLogin,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white
                  ),
                )
              ),
              const SizedBox(height: 10),
              SizedBox(width: size.width, child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don´t have a account?"),
                  TextButton(
                    onPressed: (){},
                    child: Text('Sign up',
                    style: TextStyle(
                      color: Colors.black,
                      //subrayado
                      decoration: TextDecoration.underline,
                      //negritas:
                      fontWeight: FontWeight.bold
                    )
                    )
                  )
                ]
              ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //4.15 liberar los controladores
    _emailFocus.dispose();
    _passwordFocus.dispose();
    // 2.4 Liberar espacio en memoria
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel(); // 3.9 Eliminar el timer
    super.dispose();
  }
}
