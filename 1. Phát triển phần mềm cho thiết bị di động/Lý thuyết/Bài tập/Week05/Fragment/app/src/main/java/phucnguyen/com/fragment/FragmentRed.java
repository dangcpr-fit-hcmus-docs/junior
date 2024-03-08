package phucnguyen.com.fragment;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.fragment.app.Fragment;

import java.util.Date;

public class FragmentRed extends Fragment implements FragmentCallbacks, View.OnClickListener {
    MainActivity main;
    TextView txt1Red, txt2Red;
    Button btnFirst, btnPrevious, btnNext, btnLast;
    Integer current_position, maxIndex;

    public static FragmentRed newInstance(String strArg1) {
        FragmentRed fragment = new FragmentRed();
        Bundle bundle = new Bundle(); bundle.putString("arg1", strArg1);
        fragment.setArguments(bundle);
        return fragment;
    }// newInstance

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Activities containing this fragment must implement interface: MainCallbacks
        if (!(getActivity() instanceof MainCallbacks)) {
            throw new IllegalStateException( "Activity must implement MainCallbacks");
        }
        main = (MainActivity) getActivity(); // use this reference to invoke main callbacks
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // inflate layout_red and pumbling
        LinearLayout view_layout_red = (LinearLayout) inflater.inflate(R.layout.layout_red, null);
        txt1Red = (TextView) view_layout_red.findViewById(R.id.textView1Red);
        txt2Red = (TextView) view_layout_red.findViewById(R.id.textView2Red);
        btnFirst = (Button) view_layout_red.findViewById(R.id.btnFirst);
        btnLast = (Button) view_layout_red.findViewById(R.id.btnLast);
        btnNext = (Button) view_layout_red.findViewById(R.id.btnNext);
        btnPrevious = (Button) view_layout_red.findViewById(R.id.btnPrevious);
        btnFirst.setOnClickListener(this);
        btnLast.setOnClickListener(this);
        btnNext.setOnClickListener(this);
        btnPrevious.setOnClickListener(this);

        // show string argument supplied by constructor (if any!)
        try { Bundle arguments = getArguments();
            //txt1Red.setText(arguments.getString("arg1", ""));
            }
        catch (Exception e) { Log.e("RED BUNDLE ERROR – ", "" + e.getMessage()); }

        return view_layout_red;
    }

    @Override
    public void onMsgFromMainToFragment(String strValue) {
        // receiving a message from MainActivity (it may happen at any point in time)
        String [] tokens = strValue.split("-");
        maxIndex = Integer.valueOf(tokens[0]);
        current_position = Integer.valueOf(tokens[1]);
        txt1Red.setText(tokens[2]);
        txt2Red.setText(tokens[3]);

        // check valid button
        if (current_position == 0) {
            btnPrevious.setEnabled(false);
            btnFirst.setEnabled(false);
        }
        else {
            btnPrevious.setEnabled(true);
            btnFirst.setEnabled(true);
        }
        if (current_position == maxIndex) {
            btnNext.setEnabled(false);
            btnLast.setEnabled(false);
        } else {
            btnNext.setEnabled(true);
            btnLast.setEnabled(true);
        }
    }

    @Override
    public void onClick(View view) {
        if (btnFirst.getId() == view.getId()) {main.onMsgFromFragToMain("RED-FRAG","First");}
        if (btnNext.getId() == view.getId()) {main.onMsgFromFragToMain("RED-FRAG","Next");}
        if (btnPrevious.getId() == view.getId()) {main.onMsgFromFragToMain("RED-FRAG","Previous");}
        if (btnLast.getId() == view.getId()) {main.onMsgFromFragToMain("RED-FRAG","Last");}
    }
}

