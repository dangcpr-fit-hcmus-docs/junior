package phucnguyen.com.lifecycle;


import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.DrawableRes;
import androidx.core.content.ContextCompat;

import java.util.Locale;

public class MainActivity extends Activity {

    //class variables
    private Context context;
    private int duration = Toast.LENGTH_SHORT;

    //PLUMPING: Pairing GUI controls with Java objects
    private EditText txtColorSelected;
    private Button btnExit;
    private TextView txtSpyBox;
    private LinearLayout myScreen;
    private String PREFNAME = "myPrefFile1";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //wiring GUI controls and matching Java objects
        txtColorSelected = (EditText)findViewById(R.id.editText1);
        btnExit = (Button) findViewById(R.id.button1);
        txtSpyBox = (TextView)findViewById(R.id.textView1);
        myScreen = (LinearLayout)findViewById(R.id.myScreen1);

        //set GUI watchers, listeners
        btnExit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) { finish();}
        });

        //observe (text) changes made to EditText box (color selection)
        txtColorSelected.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                /* nothing TODO, needed by interface */
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                /* nothing TODO, needed by interface */
            }

            @Override
            public void afterTextChanged(Editable editable) {
                String chosenColor =  editable.toString().toLowerCase(Locale.US);
                txtSpyBox.setText(chosenColor);
                setBackgroundColor(chosenColor,myScreen);
            }
        });

        //show the current state's name
        context = getApplicationContext();
        Toast.makeText(context, "onCreate", duration).show();
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
        Toast.makeText(context,"onDestroy",duration).show();
    }

    @Override
    protected void onPause() {
        super.onPause();
        //save state data (background color) for future use
        String chosenColor = txtSpyBox.getText().toString();
        saveStateData(chosenColor);
        Toast.makeText(context,"onPause", duration).show();
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        Toast.makeText(context,"onRestart", duration).show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        Toast.makeText(context, "onResume", duration).show();
    }

    @Override
    protected void onStop() {
        super.onStop();
        Toast.makeText(context, "onStop", duration).show();
    }

    @Override
    protected void onStart() { super.onStart();
        //if appropriate, change background color to chosen value
        updateMeUsingSavedStateData();
        Toast.makeText(context,"onStart", duration).show();
    }

    private void setBackgroundColor(String chosenColor, LinearLayout myScreen) {
        //hex color codes: 0xAARRGGBB AA:transp, RR red, GG green, BB blue
        if (chosenColor.contains("phúc")) myScreen.setBackgroundColor(0x33990033); //Color.990033
        if (chosenColor.contains("đăng")) myScreen.setBackgroundColor(0x3300ff00); //Color.GREEN
        if (chosenColor.contains("nam")) myScreen.setBackgroundColor(0x330000ff); //Color.BLUE
        if (chosenColor.contains("đức")) myScreen.setBackgroundColor(0x33ffffff); //Color.WHITE
        if (chosenColor.contains("huy")) myScreen.setBackgroundColor(0x33ff0000); //Color.WHITE
    }

    private void saveStateData(String chosenColor) {
        //this is a little <key,value> table permanently kept in memory
        SharedPreferences myPrefContainer = getSharedPreferences(PREFNAME, Activity.MODE_PRIVATE);
        //pair <key,value> to be stored represents our 'important' data
        SharedPreferences.Editor myPrefEditor = myPrefContainer.edit();
        String key = "chosenBackGroundColor", value = txtSpyBox.getText().toString();
        myPrefEditor.putString(key, value);
        myPrefEditor.commit();
    }

    private void updateMeUsingSavedStateData() {
        // (in case it exists) use saved data telling backg color
        SharedPreferences myPrefContainer = getSharedPreferences(PREFNAME, Activity.MODE_PRIVATE);
        String key = "chosenBackGroundColor";
        String defaultValue = "white";
        if (( myPrefContainer != null ) && myPrefContainer.contains(key)){
            String color = myPrefContainer.getString(key, defaultValue);
            setBackgroundColor(color, myScreen);
        }
    }//updateMeUsingSavedStateData
}