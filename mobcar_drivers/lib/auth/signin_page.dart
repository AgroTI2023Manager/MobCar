import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobcar_drivers/auth/signup_page.dart';
import 'package:mobcar_drivers/pages/dashboard.dart';
import '../global.dart';
import '../widgets/loading_dialog.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateSignInForm()
  {
    if(!emailTextEditingController.text.contains("@"))
    {
      associateMethods.showSnackBarMsg("e-mail não é válido", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      associateMethods.showSnackBarMsg("a senha deve ter pelo menos 5 caracteres ou mais", context);
    }
    else
    {
      signInUserNow();
    }
  }

  signInUserNow() async
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: "Por favor, aguarde...")
    );

    try
    {
      final User? firebaseUser = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim()
          ).catchError((onError)
          {
            Navigator.pop(context);
            associateMethods.showSnackBarMsg(onError.toString(), context);
          })
      ).user;

      if(firebaseUser != null)
      {
        DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(firebaseUser.uid);
        await ref.once().then((dataSnapshot)
        {
          if((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no")
          {
            driverName = (dataSnapshot.snapshot.value as Map)["name"];
            driverPhone = (dataSnapshot.snapshot.value as Map)["phone"];

            Navigator.push(context, MaterialPageRoute(builder: (c)=> const Dashboard()));
            associateMethods.showSnackBarMsg("Logado com sucesso.", context);
          }
          else
          {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
            associateMethods.showSnackBarMsg("Você está bloqueado. Contate o administrador: agrotierp@gmail.com", context);
          }



        });
      }
      else
      {
        Navigator.pop(context);
        FirebaseAuth.instance.signOut();
        associateMethods.showSnackBarMsg("seu registro não existe como motorista", context);
      }
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
                "assets/login.png",
                width: MediaQuery.of(context).size.width * .7,
              ),

              const SizedBox(height: 10,),

              const Text(
                "Entrar como Motorista",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "E-mail Usuario",
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

                    ElevatedButton(
                      onPressed: ()
                      {
                        validateSignInForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text("Login", style: TextStyle(color: Colors.black),),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 12,),

              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpPage()));
                },
                child: const Text(
                  "Não tem uma conta? Registre-se aqui",
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
