using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

[ExecuteInEditMode]
public class SlideController : MonoBehaviour
{
	[SerializeField]
	private int slideIndex;
	
	[SerializeField]
	private List<Slide> slides = new List<Slide>();

	private int SlideIndex
	{
		get => slideIndex;
		set
		{
			if (slides.Count == 0)
			{
				GatherSlides();
			}

			var lastSlideIndex = slideIndex;
			
			slideIndex = Mathf.Clamp(value, 0, Mathf.Max(0, slides.Count - 1));
			PlayerPrefs.SetInt("SlideIndex", slideIndex);
			ShowSlideAtIndex(slideIndex, slideIndex != lastSlideIndex);
		}
	}
	
	[SerializeField]
	private int elementIndex;

	private int ElementIndex
	{
		get => elementIndex;
		set
		{
			elementIndex = value;
			var slide = slides[slideIndex];

			for (int i = 0; i < slide.Elements.Count; i++)
			{
				slide.Elements[i].SetActive(i < elementIndex);
			}
		}
	}
	
#if UNITY_EDITOR
	[UnityEditor.MenuItem("CONTEXT/SlideController/Gather Slides")]
	private static void GatherSlidesMenuItem(UnityEditor.MenuCommand menuCommand)
	{
		(menuCommand.context as SlideController)?.GatherSlides(true);
	}
#endif

	private void GatherSlides()
	{
		GatherSlides(false);
	}
	
	private void GatherSlides(bool force)
	{
		var activeScene = SceneManager.GetActiveScene();
		
		if (Application.isPlaying == false && (activeScene.IsValid() == false || activeScene.isLoaded == false))
		{
			return;
		}

		var newSlides = activeScene.GetRootGameObjects().ToList().FindAll(x => int.TryParse(x.name, out _))
							.ConvertAll(go => go.GetComponent<Slide>());
		newSlides.RemoveAll(slide => slide == null);
		newSlides.Sort((x, y) => int.Parse(x.name).CompareTo(int.Parse(y.name)));

		slides.RemoveAll(slide => slide == null);
		if (force == false && slides.Count == newSlides.Count && slides.TrueForAll(slide => newSlides.Contains(slide)))
		{
			return;
		}

		//Make sure there are no gaps in the slide numbers
		int index = 1;
		foreach (var slide in newSlides)
		{
			int slideNameInt = int.Parse(slide.name);
			if (slideNameInt != index)
			{
				slide.name = index.ToString();
			}

			index++;
		}
		
		slides = newSlides;

		//Make sure Slide Index gets clamped
		SlideIndex = slideIndex;
	}

	private void OnEnable()
	{
		#if UNITY_EDITOR
		if (Application.isPlaying == false)
		{
			UnityEditor.SceneView.duringSceneGui += (sceneView) => OnGUI();
			UnityEditor.EditorApplication.hierarchyChanged += GatherSlides;
		}
		#endif
		SlideIndex = PlayerPrefs.GetInt("SlideIndex", slideIndex);
		GatherSlides();
	}

	private void OnGUI()
	{
		if ((Event.current.keyCode == KeyCode.LeftArrow || Event.current.keyCode == KeyCode.PageUp) && Event.current.type == EventType.KeyDown)
		{
			Back(Event.current.alt);
			Event.current.Use();
		}
		
		if ((Event.current.keyCode == KeyCode.RightArrow || Event.current.keyCode == KeyCode.PageDown) && Event.current.type == EventType.KeyDown)
		{
			Forward(Event.current.alt);
			Event.current.Use();
		}

		if ((Event.current.keyCode == KeyCode.Alpha0 ||Event.current.keyCode == KeyCode.Keypad0) && Event.current.type == EventType.KeyDown)
		{
			SlideIndex = 0;
			ElementIndex = 0;
			Event.current.Use();
		}
		
		if ((Event.current.keyCode == KeyCode.Alpha9 ||Event.current.keyCode == KeyCode.Keypad9) && Event.current.type == EventType.KeyDown)
		{
			SlideIndex = int.MaxValue;
			ElementIndex = 0;
			Event.current.Use();
		}
	}

	private void Back(bool skipSlideElements)
	{
		MoveInDirection(-1, skipSlideElements);
	}
	
	private void Forward(bool skipSlideElements)
	{
		MoveInDirection(1, skipSlideElements);
	}

	private void MoveInDirection(int direction, bool skipSlideElements = false)
	{
		var slide = slides[slideIndex];

		var newElementIndex = elementIndex + direction;
		if (skipSlideElements || newElementIndex > slide.Elements.Count)
		{
			var newSlideIndex = SlideIndex + direction;
			if (newSlideIndex > -1 && newSlideIndex < slides.Count)
			{
				SlideIndex = newSlideIndex;
				ElementIndex = 0;
			}

			return;
		}
		
		if (newElementIndex < 0 && direction < 0)
		{
			SlideIndex--;
			ElementIndex = slides[slideIndex].Elements.Count;
			return;
		}

		ElementIndex = newElementIndex;
	}

	private void ShowSlideAtIndex(int index, bool indexChanged)
	{
		if (index < 0 || index >= slides.Count)
		{
			return;
		}

		for (int i = 0; i < slides.Count; i++)
		{
			slides[i].gameObject.SetActive(i == index);
			#if UNITY_EDITOR
			if (i == index && indexChanged)
			{
				UnityEditor.Selection.activeGameObject = slides[i].gameObject;
			}
			#endif
		}
	}
}
