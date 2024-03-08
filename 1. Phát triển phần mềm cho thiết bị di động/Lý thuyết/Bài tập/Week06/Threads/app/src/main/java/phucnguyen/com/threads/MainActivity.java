package phucnguyen.com.threads;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

public class MainActivity extends Activity {

    EditText edtUserInput;
    TextView txtPercent;
    Button btnDoIt;
    ProgressBar myProgressBar;
    int totalWorks, accum, progressStep = 1;
    Handler myHandler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        edtUserInput = (EditText)findViewById(R.id.edtUserInput);
        txtPercent = (TextView) findViewById(R.id.txtPercent);
        btnDoIt = (Button) findViewById(R.id.btnDoIt);
        myProgressBar = (ProgressBar) findViewById(R.id.myProgressBar);
        btnDoIt.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doItAgain();
            }
        });
    } // onCreate

    protected void doItAgain() {
        // prepare
        totalWorks = Integer.parseInt(edtUserInput.getText().toString());
        accum = 0;
        myProgressBar.setMax(totalWorks);
        myProgressBar.setProgress(0);
        btnDoIt.setEnabled(false);
        // start thread
        Thread myBackGroundThread = new Thread(backgroundTask,"backAlias1");
        myBackGroundThread.start();
    }

    private Runnable backgroundTask = new Runnable() {
        @Override
        public void run() {
            try {
                while (accum < myProgressBar.getMax()){
                    Thread.sleep(5);
                    myHandler.post(foregroundRunnable);
                }
            } catch (Exception e) {
                Log.e("<<ForegroundRunnable", e.getMessage());
            }
        }
    };

    private Runnable foregroundRunnable = new Runnable() {
        @Override
        public void run() {
            try {
                myProgressBar.incrementProgressBy(progressStep);
                accum+= progressStep;

                int percent = (int)((float)(accum*100/totalWorks));
                txtPercent.setText(percent + "%");

                if (accum >= myProgressBar.getMax()) {
                    btnDoIt.setEnabled(true);
                    myProgressBar.setProgress(0);
                    txtPercent.setText("0%");
                }
            } catch (Exception e) {
                Log.e("ForegroundRunnable",e.getMessage());
            }
        }
    };
}