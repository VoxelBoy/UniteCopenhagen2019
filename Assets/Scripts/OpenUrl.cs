using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Button))]
public class OpenUrl : MonoBehaviour
{

	public string url;

	public void Awake()
	{
		GetComponent<Button>().onClick.AddListener(OnButtonClicked);
	}

	public void OnButtonClicked()
	{
		Application.OpenURL(url);
	}
}
