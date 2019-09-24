using UnityEditor;
using UnityEngine;

public static class SwitchShaders
{
    [MenuItem("Tools/Switch Shaders")]
    private static void DoSwitchShaders()
    {
        var materialGuids = AssetDatabase.FindAssets("t:material", new[] {"Assets/Content/Models"});
        foreach (var materialGuid in materialGuids)
        {
            var material = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath(materialGuid));
            var shaderName = material.shader.name;
            var newShaderName = shaderName.Contains("Completed")
                ? shaderName.Replace("/Completed", string.Empty)
                : shaderName.Replace("Custom/", "Custom/Completed/");
            material.shader = Shader.Find(newShaderName);
        }
    }
}