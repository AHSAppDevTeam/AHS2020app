package com.example.ahsapptest3;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import androidx.annotation.Nullable;

public class BulletinDatabase extends SQLiteOpenHelper {

    private static final String TAG = "BulletinDatabase";
    private static final String current_Table = "BulletinDatabase"; //may change later

    private static final String BUL_ID = "BUL_ID";
    static final int BUL_COL = 1;
    private static final String TIME = "TIME";
    static final int TIME_COL = 2;
    private static final String TITLE = "TITLE";
    static final int TITLE_COL = 3;
    private static final String BODY = "BODY";
    static final int BODY_COL = 4;
    private static final String TYPE = "TYPE";
    static final int TYPE_COL = 5;
    private static final String READ = "READ";
    static final int READ_COL = 6;

    public BulletinDatabase(@Nullable Context context)
    {
        super(context, current_Table, null, 1);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String createTable =
                "CREATE TABLE " + current_Table +
                "(ID INTEGER PRIMARY KEY AUTOINCREMENT, " +
                BUL_ID + " TEXT," +
                TIME + " INTEGER," +
                TITLE + " TEXT," +
                BODY + " TEXT," +
                TYPE + " TEXT," +
                READ + " INTEGER);";
        db.execSQL(createTable);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + current_Table);
        onCreate(db);
    }

    public boolean add(Bulletin_Data... datas)
    {
        boolean succeeded = true;
        for(Bulletin_Data data: datas) {
            SQLiteDatabase db = this.getWritableDatabase();
            ContentValues values = new ContentValues();
            values.put(BUL_ID, data.getID());
            values.put(TIME, data.getTime());
            values.put(TITLE, data.getTitle());
            values.put(BODY, data.getBodyText());
            values.put(TYPE, data.getType().toString());
            values.put(READ, (data.isAlready_read()) ? 1 : 0);

            long result = db.insert(current_Table, null, values);
            succeeded = succeeded && (result != -1);
        }

        // if inserted incorrectly -1 is the return value
        return succeeded;
    }

    public boolean alreadyAdded(String ID)
    {
        String selectQuery = "SELECT "+ BUL_ID +" FROM " + current_Table + " WHERE  " + BUL_ID + " = '" + ID + "'";
        Cursor cursor = this.getWritableDatabase().rawQuery(selectQuery,null);
        boolean alreadyAdded = cursor.getCount() > 0;
        cursor.close();
        return alreadyAdded;
    }

    public boolean getReadStatusByID(String ID)
    {
        String query = "SELECT * FROM " + current_Table
                + " WHERE  " + BUL_ID + " = '" + ID + "'";
        Cursor data = this.getWritableDatabase().rawQuery(query, null);

        if(data.getCount()<1) // not found
            return false;
        data.moveToFirst();

        boolean read = data.getInt(READ_COL) == 1;
        data.close();
        return read;


    }

    public void updateReadStatus(Bulletin_Data data)
    {
        String query = "UPDATE " + current_Table
                + " SET " + READ + " = '" + (data.isAlready_read() ? 1 : 0)
                + "' WHERE " + BUL_ID + " = '" + data.getID() + "'";
        this.getWritableDatabase().execSQL(query);
    }

    public void delete(Bulletin_Data data)
    {
        String query =
                "DELETE FROM " + current_Table +
                        " WHERE " + BUL_ID + " = '" + data.getID() +"'";
        this.getWritableDatabase().execSQL(query);
    }

    public void deleteAll()
    {
        String query =
                "DELETE FROM " + current_Table;
        this.getWritableDatabase().execSQL(query);
    }
}
