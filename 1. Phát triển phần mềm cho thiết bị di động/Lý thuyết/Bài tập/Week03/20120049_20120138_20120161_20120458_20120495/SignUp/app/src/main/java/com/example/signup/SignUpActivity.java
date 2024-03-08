package com.example.signup;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;

public class SignUpActivity extends AppCompatActivity{

    private EditText username, password, retype, birthday;
    private Button select, signup, reset;
    private RadioGroup gender;
    private RadioButton male,female;
    private CheckBox tennis, fotbal, others;

    public static final String NAME = "NAME";
    public static final String PASS = "PASS";
    public static final String BIRTH = "BIRTH";
    public static final String GENDER = "GENDER";
    public static final String HOBBIES = "HOBBIES";

    public static final int REQUEST_CODE = 2022;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

        username = (EditText) findViewById(R.id.edtUsername);
        password = (EditText) findViewById(R.id.edtPassword);
        retype = (EditText) findViewById(R.id.edtRetype);
        birthday = (EditText) findViewById(R.id.edtBirthday);

        select = (Button) findViewById(R.id.btnSelect);
        signup = (Button) findViewById(R.id.btnSignUp);
        reset = (Button) findViewById(R.id.btnReset);

        gender = (RadioGroup) findViewById(R.id.radioGroupGender);
        male = (RadioButton) findViewById(R.id.radMale);
        female = (RadioButton) findViewById(R.id.radMale);

        tennis = (CheckBox) findViewById(R.id.chkTennis);
        fotbal = (CheckBox) findViewById(R.id.chkFutbal);
        others = (CheckBox) findViewById(R.id.chkOthers);

        select.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(SignUpActivity.this, GetDayActivity.class);
                startActivityForResult(intent,REQUEST_CODE);
            }
        });

        signup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String name = username.getText().toString();
                String pass = password.getText().toString();
                String retype_pass = retype.getText().toString();
                String birth = birthday.getText().toString();
                String gender = "";
                String hobbies = "";

                if(male.isChecked())
                {
                    gender = "Male";
                }
                else if(female.isChecked())
                {
                    gender = "Female";
                }

                if(tennis.isChecked())
                {
                    hobbies = hobbies +"Tennis, ";
                }
                if(fotbal.isChecked())
                {
                    hobbies = hobbies +"Futbal, ";
                }
                if(others.isChecked())
                {
                    hobbies = hobbies +"Others, ";
                }

                if(hobbies != "")
                {
                    hobbies = hobbies.substring(0,hobbies.length()-2);
                }

                if (pass.equals(retype_pass))
                {
                    if(checkDate(birth) != true)
                    {
                        Toast.makeText(SignUpActivity.this, "Birthday must have the form:'dd/mm/yyyy'!", Toast.LENGTH_SHORT).show();
                    }
                    else if(TextUtils.isEmpty(username.getText().toString()) | TextUtils.isEmpty(password.getText().toString()))
                    {
                        Toast.makeText(SignUpActivity.this, "Username and Password are not empty!", Toast.LENGTH_SHORT).show();
                    }
                    else
                    {
                        int passlength = pass.length();
                        String temp = "";
                        for(int i = 0;i<passlength;++i)
                        {
                            temp = temp + "*";
                        }

                        byExtras(name,temp,birth,gender,hobbies);
                    }
                }
                else
                {
                    Toast.makeText(SignUpActivity.this, "Password does not match!", Toast.LENGTH_SHORT).show();
                }
            }
        });

        reset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                username.setText("");
                password.setText("");
                retype.setText("");
                birthday.setText("");

                gender.clearCheck();

                tennis.setChecked(false);
                fotbal.setChecked(false);
                others.setChecked(false);
            }
        });
    }

    public void byExtras(String name, String pass, String birth, String gender, String hobbies){
        Intent intent = new Intent(SignUpActivity.this, MainActivity.class);

        intent.putExtra(NAME, name);
        intent.putExtra(PASS, pass);
        intent.putExtra(BIRTH, birth);
        intent.putExtra(GENDER, gender);
        intent.putExtra(HOBBIES, hobbies);

        startActivity(intent);
    }

    public boolean checkDate(String datetime){
        boolean check = true;
        if (datetime.length() != 10)
        {
            check = false;
        }
        else
        {
            for(int i = 0;i <= 9;++i)
            {
                if((i == 2 | i == 5) & datetime.charAt(i)!='/')
                {
                    check = false;
                }
                else if((i != 2 & i != 5) & (datetime.charAt(i)<'0' | datetime.charAt(i)>'9'))
                {
                    check = false;
                }
            }
        }
        return check;
    }

    protected void onActivityResult(int requestCode, int result, Intent data) {
        super.onActivityResult(requestCode,result,data);
        if(requestCode == REQUEST_CODE) {
            switch (requestCode){
                case GetDayActivity.REQUEST_PIN:
                    String re = data.getStringExtra(GetDayActivity.DATETIME);
                    birthday.setText(re);
                    break;
                default:
                    break;
            }
        }
    }
}


