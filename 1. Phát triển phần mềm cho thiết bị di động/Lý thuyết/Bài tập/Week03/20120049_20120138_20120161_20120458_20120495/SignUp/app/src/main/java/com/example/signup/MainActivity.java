package com.example.signup;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Process;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private TextView tvUsername, tvPassword, tvBirthday, tvGender, tvHobbies;
    private Button exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        tvUsername = (TextView) findViewById(R.id.tv_Username);
        tvPassword = (TextView) findViewById(R.id.tv_Password);
        tvBirthday = (TextView) findViewById(R.id.tv_Birthday);
        tvGender = (TextView) findViewById(R.id.tv_Gender);
        tvHobbies = (TextView) findViewById(R.id.tv_Hobbies);

        Intent intent = getIntent();
        String name = intent.getStringExtra(SignUpActivity.NAME);
        String pass = intent.getStringExtra(SignUpActivity.PASS);
        String birth = intent.getStringExtra(SignUpActivity.BIRTH);
        String gender = intent.getStringExtra(SignUpActivity.GENDER);
        String hobbies = intent.getStringExtra(SignUpActivity.HOBBIES);

        tvUsername.setText(name);
        tvPassword.setText(pass);
        tvBirthday.setText(birth);
        tvGender.setText(gender);
        tvHobbies.setText(hobbies);

        exit = (Button) findViewById(R.id.btnExit);

        exit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                moveTaskToBack(true);
                android.os.Process.killProcess(android.os.Process.myPid());
                System.exit(1);
            }
        });
    }
}