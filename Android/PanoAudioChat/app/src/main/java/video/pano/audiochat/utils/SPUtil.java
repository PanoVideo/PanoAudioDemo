package video.pano.audiochat.utils;

import android.content.Context;
import android.content.SharedPreferences;

public class SPUtil {

    public static final String DEFAULT_FILE_NAME = "default_pref";
    public static final String KEY_USER_NAME = "user_name";
    public static final String KEY_ROOM_ID = "room_id";

    public static void setValue(Context context, String key, Object value) {
        setValue(context, DEFAULT_FILE_NAME, key, value);
    }

    public static void setValue(Context context, String fileName, String key, Object value) {
        SharedPreferences.Editor editor = context.getSharedPreferences(fileName, Context.MODE_PRIVATE).edit();
        if (value instanceof String) {
            editor.putString(key, (String) value);
        } else if (value instanceof Integer) {
            editor.putInt(key, (Integer) value);
        } else if (value instanceof Boolean) {
            editor.putBoolean(key, (Boolean) value);
        } else if (value instanceof Float) {
            editor.putFloat(key, (Float) value);
        } else if (value instanceof Long) {
            editor.putLong(key, (Long) value);
        } else {
            editor.putString(key, value.toString());
        }
        editor.apply();
    }

    public static Object getValue(Context context, String key, Object defaultValue) {
        return getValue(context, DEFAULT_FILE_NAME, key, defaultValue);
    }

    public static Object getValue(Context context, String fileName, String key, Object defaultValue) {
        SharedPreferences sp = context.getSharedPreferences(fileName, Context.MODE_PRIVATE);
        if (defaultValue instanceof String) {
            return sp.getString(key, (String) defaultValue);
        } else if (defaultValue instanceof Integer) {
            return sp.getInt(key, (Integer) defaultValue);
        } else if (defaultValue instanceof Boolean) {
            return sp.getBoolean(key, (Boolean) defaultValue);
        } else if (defaultValue instanceof Float) {
            return sp.getFloat(key, (Float) defaultValue);
        } else if (defaultValue instanceof Long) {
            return sp.getLong(key, (Long) defaultValue);
        }
        return null;
    }
}
