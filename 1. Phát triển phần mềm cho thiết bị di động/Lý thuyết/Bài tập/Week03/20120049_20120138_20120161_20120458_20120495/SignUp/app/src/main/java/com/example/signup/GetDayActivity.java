package com.example.signup;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Toast;

import java.util.Calendar;

public class GetDayActivity extends AppCompatActivity {

    private DatePicker datePicker;
    private Button buttonDate;

    public static final String DATETIME = "DATETIME";

    public static final int REQUEST_PIN = 2022;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_getday);

        this.buttonDate = (Button) this.findViewById(R.id.button_date);
        this.datePicker = (DatePicker) this.findViewById(R.id.datePicker);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());

        int year = calendar.get(Calendar.YEAR);
        int month  = calendar.get(Calendar.MONTH);
        int day = calendar.get(Calendar.DAY_OF_MONTH);


        this.buttonDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int year = datePicker.getYear();
                int month = datePicker.getMonth();
                int day = datePicker.getDayOfMonth();

                String result = "";

                if(day<10)
                {
                    result = result+"0" + String.valueOf(day)+"/";
                }
                else
                {
                    result = result + String.valueOf(day)+"/";
                }
                if(month<9)
                {
                    result = result+"0" + String.valueOf(month+1)+"/";
                }
                else
                {
                    result = result + String.valueOf(month+1)+"/";
                }
                result = result + String.valueOf(year);

                Intent intent = new Intent();
                intent.putExtra(DATETIME,result);
                setResult(REQUEST_PIN,intent);
                finish();
            }
        });
    }

    public void byExtras(String datetime){
        Intent intent = new Intent(GetDayActivity.this, SignUpActivity.class);
        intent.putExtra(DATETIME, datetime);
        startActivity(intent);
    }
}
