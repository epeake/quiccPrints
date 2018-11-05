package com.ipproject.quicprints;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class LoginActivity extends AppCompatActivity {

    private Button loginButton;
    private EditText emailEditText, passwdEditText;
    private FirebaseAuth usrAuth;
    private FirebaseAuth.AuthStateListener fireBAuthStateListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // listener that is called whenever the user logs on or the state of the usrAuth
        // is changed (log in or logout) but logout cannot happen here
        fireBAuthStateListener = new FirebaseAuth.AuthStateListener() {
            @Override
            public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
                FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                // in case the user is already logged in just redirect to the main
                // this should not happen but in case it does there is a measure taken
                if(user != null) {
                    Intent intent =  new Intent(
                            LoginActivity.this,
                            MainActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(intent);
                    finish();
                    return;
                }
            }
        };

        usrAuth = FirebaseAuth.getInstance();

        loginButton = findViewById(R.id.loginButton);
        emailEditText = findViewById(R.id.emailEditText);
        passwdEditText = findViewById(R.id.psswdEditText);


        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //declared as final because it should not change in a login attempt
                final String email = emailEditText.getText().toString();
                final String psswd = passwdEditText.getText().toString();

                usrAuth.signInWithEmailAndPassword(email, psswd).addOnCompleteListener(
                    LoginActivity.this, new OnCompleteListener<AuthResult>() {
                        // this is a callback after login has been completed
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if(!task.isSuccessful()) {
                                Toast.makeText(
                                        LoginActivity.this,
                                        "Error logging in",
                                        Toast.LENGTH_SHORT).show();
                            }
                        }
                });
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        usrAuth.addAuthStateListener(fireBAuthStateListener);
    }

    @Override
    protected void onStop() {
        super.onStop();
        usrAuth.removeAuthStateListener(fireBAuthStateListener);
    }
}
