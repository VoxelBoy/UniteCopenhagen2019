using UnityEditor;
using UnityEditor.ShortcutManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SwitchRenderPipeline
{
    [MenuItem("Tools/Switch Render Pipeline")]
    [Shortcut("SwitchRenderPipeline", null, KeyCode.R, ShortcutModifiers.Alt | ShortcutModifiers.Shift)]
    private static void DoSwitchRenderPipeline()
    {
        var renderPipelineAsset = AssetDatabase.LoadAssetAtPath<UniversalRenderPipelineAsset>("Assets/UniversalRenderPipelineAsset.asset");
        GraphicsSettings.renderPipelineAsset = GraphicsSettings.renderPipelineAsset != null ? null : renderPipelineAsset;
        var activeRenderPipeline = GraphicsSettings.renderPipelineAsset != null ? "URP" : "Built-in RP";
        SceneView.lastActiveSceneView.ShowNotification(new GUIContent($"Switched to {activeRenderPipeline}"));
    }
}
