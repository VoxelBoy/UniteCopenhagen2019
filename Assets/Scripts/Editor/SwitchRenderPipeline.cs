using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public static class SwitchRenderPipeline
{
    [MenuItem("Tools/Switch Render Pipeline &#R")]
    private static void DoSwitchRenderPipeline()
    {
        var renderPipelineAsset = AssetDatabase.LoadAssetAtPath<RenderPipelineAsset>("Assets/UniversalRenderPipelineAsset.asset");
        GraphicsSettings.renderPipelineAsset = GraphicsSettings.renderPipelineAsset != null ? null : renderPipelineAsset;
        var activeRenderPipeline = GraphicsSettings.renderPipelineAsset != null ? "UniversalRP" : "Built-in RP";
        SceneView.lastActiveSceneView.ShowNotification(new GUIContent($"Switched to {activeRenderPipeline}"));
    }
}
