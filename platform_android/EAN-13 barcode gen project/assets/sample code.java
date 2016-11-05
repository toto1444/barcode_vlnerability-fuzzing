import android.app.Activity;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import 	android.graphics.Typeface;
 
public class AndroidEAN13Activity extends Activity {

    /** Called when the activity is first created. */

    @Override
    public void onCreate(Bundle icicle) {

        super.onCreate(icicle);
        // ToDo add your GUI initialization code here
        this.setContentView(R.layout.main);
        TextView t = (TextView)findViewById(R.id.barcode);

        // set barcode font for TextView. ttf file must be placed is assets/fonts
        Typeface font = Typeface.createFromAsset(this.getAssets(), "fonts/EanP72Tt Normal.Ttf");

        t.setTypeface(font);
        // generate barcode string

        EAN13CodeBuilder bb = new EAN13CodeBuilder("124958761310");

        t.setText(bb.getCode());

    }

}
