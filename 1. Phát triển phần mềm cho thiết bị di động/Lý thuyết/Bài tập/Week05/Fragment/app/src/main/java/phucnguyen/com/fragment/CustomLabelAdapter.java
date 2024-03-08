package phucnguyen.com.fragment;

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
    String[] ids;
    Integer[] thumbnails;

    public CustomLabelAdapter(Context context, int layout, String[] ids, Integer[] thumbnails){
        super(context, layout, ids);
        this.context = context;
        this.thumbnails = thumbnails;
        this.ids = ids;
    }

    @Override
    public View getView(int position,View convertView, ViewGroup parent) {
        LayoutInflater inflater = ((Activity) context).getLayoutInflater();
        View row = inflater.inflate(R.layout.custom_row_icon_label,null);
        TextView label1 = row.findViewById(R.id.label1);
        ImageView icon = row.findViewById(R.id.icon);
        label1.setText(ids[position]);
        icon.setImageResource(thumbnails[position]);
        return (row);
    }

}
