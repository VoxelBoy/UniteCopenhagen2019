using System;
using System.Linq;
using TMPro;
using UnityEditor;

public class SlideContextMenu
{
    [MenuItem("CONTEXT/Slide/Gather text elements")]
    private static void GatherTextElements(MenuCommand menuCommand)
    {
        var slide = menuCommand.context as Slide;
        var elements = slide.GetComponentsInChildren<TextMeshProUGUI>(true).ToList().ConvertAll(x => x.gameObject);
        elements.RemoveAll(x => x.name.Equals("Title", StringComparison.InvariantCulture));
        slide.Elements = elements;
    }
}