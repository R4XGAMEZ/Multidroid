// android/app/src/main/java/com/multidroid/shizuku/ShizukuBridge.java

package com.multidroid.shizuku;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import rikka.shizuku.Shizuku;

public class ShizukuBridge {

    private static final String TAG = "ShizukuBridge";

    // Check if Shizuku is available and permission granted
    public static boolean isAvailable() {
        try {
            return Shizuku.pingBinder();
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean hasPermission() {
        try {
            if (Shizuku.isPreV11()) {
                return false;
            }
            return Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED;
        } catch (Exception e) {
            return false;
        }
    }

    public static void requestPermission(int requestCode) {
        Shizuku.requestPermission(requestCode);
    }

    // Execute ADB shell command via Shizuku
    public static String execCommand(String command) {
        try {
            Process process = Runtime.getRuntime().exec(new String[]{"sh", "-c", command});
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream())
            );
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            process.waitFor();
            return output.toString().trim();
        } catch (Exception e) {
            Log.e(TAG, "Command failed: " + command, e);
            return "";
        }
    }

    // Launch app in freeform window with specific bounds
    // bounds format: "left,top,right,bottom"
    public static boolean launchInFreeform(
            String packageName,
            String activityName,
            int left, int top, int right, int bottom) {
        try {
            String bounds = left + "," + top + "," + right + "," + bottom;
            String cmd = "am start " +
                "--activity-launch-bounds \"" + bounds + "\" " +
                "-n " + packageName + "/" + activityName;
            String result = execCommand(cmd);
            Log.d(TAG, "Freeform launch: " + result);
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Freeform launch failed", e);
            return false;
        }
    }

    // Enable freeform mode
    public static void enableFreeformMode() {
        execCommand("settings put global enable_freeform_support 1");
        execCommand("settings put global force_resizable_activities 1");
    }

    // Check if freeform is supported
    public static boolean isFreeformSupported() {
        String result = execCommand("settings get global enable_freeform_support");
        return "1".equals(result.trim());
    }

    // Force stop an app instance
    public static void forceStopApp(String packageName) {
        execCommand("am force-stop " + packageName);
    }

    // Get screen size
    public static int[] getScreenSize() {
        String result = execCommand("wm size");
        // Parse "Physical size: 1080x2400"
        try {
            String[] parts = result.split(": ")[1].split("x");
            return new int[]{
                Integer.parseInt(parts[0].trim()),
                Integer.parseInt(parts[1].trim())
            };
        } catch (Exception e) {
            return new int[]{1080, 2400}; // default
        }
    }

    // Set proxy for a specific app (Android 10+)
    public static void setProxyForApp(String packageName, String host, int port) {
        // Using network settings via ADB
        execCommand("settings put global http_proxy " + host + ":" + port);
    }

    // Clear proxy
    public static void clearProxy() {
        execCommand("settings delete global http_proxy");
    }
}
