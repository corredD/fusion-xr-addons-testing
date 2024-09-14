using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Fusion;
using UnityEngine.UI;
using TMPro;
using Unity.VisualScripting;

public class UINetCallback : NetworkBehaviour
{
    public TMP_Text alabel;
    public string alabel_default="default";
    //private ColorPicker cpikcer;
    private Slider aslider;
    private Toggle atoggle;
    [Networked, OnChangedRender(nameof(OnChangeSlider))]
    public float slider_value {get;set;}
    [Networked, OnChangedRender(nameof(OnChangeColor))]
    public Color color_value {get;set;}    
    [Networked, OnChangedRender(nameof(OnChangeToggle))]
    public bool toggle_value {get;set;}        
    // Start is called before the first frame update
    void Awake()
    {
        aslider = GetComponent<Slider>();
        atoggle = GetComponent<Toggle>();
        //cpikcer = GetComponent<ColorPicker>();
        //automaticalyl add callback to slider and toggle
        if (aslider) aslider.onValueChanged.AddListener(delegate { SetSliderValue(); });
        if (atoggle) atoggle.onValueChanged.AddListener(delegate { SetToggleValue(); });
    }

    public void OnChangeSlider()
    {
        float new_value = slider_value;
        //SetValueWithoutNotify
        if (aslider) aslider.value = new_value;
        if (alabel) alabel.text = (alabel_default+" "+new_value.ToString());
        Debug.Log("OnChangeSlider "+new_value.ToString());
    }  

    public void OnChangeToggle()
    {
        bool new_value = toggle_value;
        if (atoggle) atoggle.isOn = new_value;
        Debug.Log("OnChangeToggle "+new_value.ToString());
    }  

    public void OnChangeColor()
    {
        Color new_value = color_value;
        //if (cpikcer) {
        //    cpikcer.CurrentColor = new_value;
        //}
    }      

    public void SetSliderValue()
    {
        slider_value = aslider.value;
    }

    public void SetToggleValue()
    {
        toggle_value = atoggle.isOn;
    }   
}
