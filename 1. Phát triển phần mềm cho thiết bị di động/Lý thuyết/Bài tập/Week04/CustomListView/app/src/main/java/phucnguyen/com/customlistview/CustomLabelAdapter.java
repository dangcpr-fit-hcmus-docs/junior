package phucnguyen.com.customlistview;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class CustomLabelAdapter extends ArrayAdapter<String> {
    Context context;
    String[] names, phones;
    Integer[] thumbnails;

    public CustomLabelAdapter(Context context, int layout, String[] names, String[] phones, Integer[] thumbnails){
        super(context, layout, names);
        this.context = context;
        this.thumbnails = thumbnails;
        this.names = names;
        this.phones = phones;
    }

    @Override
    public View getView(int position,View convertView, ViewGroup parent) {
        LayoutInflater inflater = ((Activity) context).getLayoutInflater();
        View row = inflater.inflate(R.layout.custom_row_icon_label,null);
        TextView label1 = row.findViewById(R.id.label1);
        TextView label2 = row.findViewById(R.id.label2);
        ImageView icon = row.findViewById(R.id.icon);
        label1.setText(names[position]);
        label2.setText(phones[position]);
        icon.setImageResource(thumbnails[position]);
        return (row);
    }
}
