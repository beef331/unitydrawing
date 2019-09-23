using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Drawer : MonoBehaviour
{

    [SerializeField]
    private float brushRadius = 5;
    [SerializeField]
    private float decaySpeed = .5f;
    private Color[] cols = new Color[8];
    private int currentCol = 0;
    [SerializeField]
    private RenderTexture rt;
    private Material material;
    private Vector4 lastPos, lastLastPos;
    [SerializeField]
    private float colSwitchDelay = .1f;
    private float lastSwitch = 0;
    [SerializeField]
    private float maxSize = 200, minSize = 10;
    private float alpha = 1;


    void Start()
    {
        rt = new RenderTexture(Screen.width, Screen.height, 0);
        rt.Create();
        material = new Material(Shader.Find("Hidden/Draw"));
        material.SetFloat("_Decay", decaySpeed);
        Clear();
    }

    void InitColors()
    {
        for (int i = 0; i < cols.Length; i++)
        {
            cols[i] = new Color(Random.value + .1f, Random.value + .1f, Random.value + .1f, 1);
        }
        material.SetColor("_Color", cols[0]);
    }

    void Clear()
    {
        RenderTexture buffer = RenderTexture.GetTemporary(rt.descriptor);
        Graphics.Blit(rt, buffer, material, 1);
        Graphics.Blit(buffer, rt);
        buffer.Release();
        InitColors();
    }
    void DrawOnTex()
    {
        RenderTexture buffer = RenderTexture.GetTemporary(rt.descriptor);
        Graphics.Blit(rt, buffer, material, 0);
        Graphics.Blit(buffer, rt);
        buffer.Release();
    }

    void Update()
    {
        Vector4 mousePos;
        mousePos = new Vector4(Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height, brushRadius, 0);
        material.SetVector("_MousePos", mousePos);
        if (Time.time - lastSwitch >= colSwitchDelay)
        {
            currentCol = (currentCol + cols.Length + 1) % cols.Length;
            lastSwitch = Time.time;
        }
        Color thisFrameCol = Color.Lerp(cols[currentCol], cols[(currentCol + 1 + cols.Length) % cols.Length], (Time.time - lastSwitch) / colSwitchDelay);
        thisFrameCol.a = alpha;
        material.SetColor("_Color",thisFrameCol);
        //brushRadius = Mathf.Clamp(Mathf.Abs(Mathf.Sin(Time.time)) * maxSize, minSize, maxSize);
        if(Input.GetKey(KeyCode.O)){
                    brushRadius = Mathf.Clamp(brushRadius - Time.deltaTime * 20f, minSize, maxSize);
        }
        if(Input.GetKey(KeyCode.P)){
                    brushRadius = Mathf.Clamp(brushRadius + Time.deltaTime * 20f, minSize, maxSize);
        }
        if(Input.GetKey(KeyCode.U)){
                    alpha = Mathf.Clamp(alpha - Time.deltaTime,0,1);
        }
        if(Input.GetKey(KeyCode.I)){
                    alpha = Mathf.Clamp(alpha + Time.deltaTime,0,1);
        }
        if (Input.GetMouseButton(0))
        {
            DrawOnTex();
        }
        lastLastPos = lastPos;
        lastPos = mousePos;
        material.SetVector("_LastPos", lastPos);
        material.SetVector("_LastLastPos", lastLastPos);
        if (Input.GetKeyDown(KeyCode.Backspace))
        {
            Clear();
        }
    }
    void OnGUI()
    {
        Graphics.DrawTexture(new Rect(0, 0, Screen.width, Screen.height), rt);
    }
}
