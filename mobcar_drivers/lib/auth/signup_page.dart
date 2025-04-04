import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobcar_drivers/auth/signin_page.dart';
import 'package:mobcar_drivers/pages/dashboard.dart';

import '../global.dart';
import '../widgets/loading_dialog.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();

  validateSignUpForm()
  {
    if(userNameTextEditingController.text.trim().length < 3)
    {
      associateMethods.showSnackBarMsg("o nome deve ter pelo menos 3 ou mais caracteres", context);
    }
    else if(!emailTextEditingController.text.contains("@"))
    {
      associateMethods.showSnackBarMsg("e-mail não é válido", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      associateMethods.showSnackBarMsg("a senha deve ter pelo menos 5 caracteres ou mais", context);
    }
    else if(vehicleModelTextEditingController.text.trim().isEmpty)
    {
      associateMethods.showSnackBarMsg("por favor informe o modelo do carro", context);
    }
    else if(vehicleColorTextEditingController.text.trim().isEmpty)
    {
      associateMethods.showSnackBarMsg("por favor informe a cor do carro", context);
    }
    else if(vehicleNumberTextEditingController.text.trim().isEmpty)
    {
      associateMethods.showSnackBarMsg("por favor informe a placa do carro", context);
    }
    else
    {
      signUpUserNow();
    }
  }

  signUpUserNow() async
  {
    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageText: "Por favor, aguarde...")
    );

    try
    {
      final User? firebaseUser = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
        ).catchError((onError)
        {
          Navigator.pop(context);
          associateMethods.showSnackBarMsg(onError.toString(), context);
        })
      ).user;

      Map carDataMap =
      {
        "carColor": vehicleColorTextEditingController.text.trim(),
        "carModel": vehicleModelTextEditingController.text.trim(),
        "carNumber": vehicleNumberTextEditingController.text.trim(),
      };

      Map driverDataMap =
      {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no",
        "car_details":carDataMap,
      };
      FirebaseDatabase.instance.ref().child("drivers").child(firebaseUser.uid).set(driverDataMap);

      Navigator.pop(context);
      associateMethods.showSnackBarMsg("Conta criada com sucesso.", context);
      Navigator.push(context, MaterialPageRoute(builder: (c)=> const Dashboard()));
    }
    on FirebaseAuthException catch(e)
    {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              const SizedBox(height: 122,),

              Image.asset(
                "assets/signup.png",
                width: MediaQuery.of(context).size.width * .7,
              ),

              const SizedBox(height: 10,),

              const Text(
                "Registre a Nova Conta",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Nome Usuario",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Celular Usuario",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email Usuario",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Senha Usuario",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Modelo Carro",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    TextField(
                      controller: vehicleColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Cor Carro",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Placa Carro",
                          labelStyle: TextStyle(fontSize: 14)
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    ElevatedButton(
                      onPressed: ()
                      {
                        validateSignUpForm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text("Registre-se", style: TextStyle(color: Colors.black),),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 12,),

              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignInPage()));
                },
                child: const Text(
                  "Já tem uma conta? Entre aqui",
                  style: TextStyle(
                    color: Colors.grey,
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
