using UnityEngine;
using System.Collections;
using TMPro;
public class ZzzLog : MonoBehaviour
{
    public TMP_Text logText;
    uint qsize = 15;  // number of messages to keep
    Queue myLogQueue = new Queue();

    void Start() {
        Debug.Log("Started up logging.");
    }

    void OnEnable() {
        Application.logMessageReceived += HandleLog;
    }

    void OnDisable() {
        Application.logMessageReceived -= HandleLog;
    }

    void HandleLog(string logString, string stackTrace, LogType type) {
        if (type == LogType.Warning) return;
        myLogQueue.Enqueue("[" + type + "] : " + logString);
        if (type == LogType.Exception)
            myLogQueue.Enqueue(stackTrace);
        while (myLogQueue.Count > qsize)
            myLogQueue.Dequeue();
    }

    void Update() {
        if(logText) logText.text = string.Join("\n", myLogQueue.ToArray());
    }

    void OnGUI() {
        if(logText) return;
        GUILayout.BeginArea(new Rect(Screen.width - 400, 0, 400, Screen.height));
        GUILayout.Label("\n" + string.Join("\n", myLogQueue.ToArray()));
        GUILayout.EndArea();
    }
}