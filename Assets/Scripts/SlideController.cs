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

	public int SlideIndex
	{
		get { return slideIndex; }
		set
		{
			if (slides.Count == 0)
			{
				GatherSlidesInScene();
			}

			var lastSlideIndex = slideIndex;
			
			slideIndex = Mathf.Clamp(value, 0, slides.Count - 1);
			PlayerPrefs.SetInt("SlideIndex", slideIndex);
			ShowSlideAtIndex(slideIndex, slideIndex != lastSlideIndex);
		}
	}
	
	[SerializeField]
	private int elementIndex;

	public int ElementIndex
	{
		get { return elementIndex; }
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

	private void GatherSlidesInScene()
	{
		var activeScene = SceneManager.GetActiveScene();
		
		if (Application.isPlaying == false && (activeScene.IsValid() == false || activeScene.isLoaded == false))
		{
			return;
		}

		var newSlides = activeScene.GetRootGameObjects().ToList().FindAll(x => int.TryParse(x.name, out _))
							.ConvertAll(go => go.GetComponent<Slide>());
		newSlides.Sort((x, y) => int.Parse(x.name).CompareTo(int.Parse(y.name)));

		if (slides.Count == newSlides.Count && slides.TrueForAll(slide => newSlides.Contains(slide)))
		{
			return;
		}
		
		//Make sure there are no gaps in the slide numbers
		int index = 1;
		for (int i = 0; i < slides.Count; i++)
		{
			int slideNameInt = int.Parse(slides[i].name);
			if (slideNameInt != index)
			{
				slides[i].name = index.ToString();
			}

			index++;
		}

		//Make sure Slide Index gets clamped
		SlideIndex = slideIndex;
	}

	private void OnEnable()
	{
		#if UNITY_EDITOR
		if (Application.isPlaying == false)
		{
			UnityEditor.SceneView.duringSceneGui += (sceneView) => OnGUI();
			UnityEditor.EditorApplication.hierarchyChanged += GatherSlidesInScene;
		}
		#endif
		SlideIndex = PlayerPrefs.GetInt("SlideIndex", slideIndex);
		GatherSlidesInScene();
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
			Debug.LogError("Slide index out of bounds: " + index);
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
