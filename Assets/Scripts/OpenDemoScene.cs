using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

[RequireComponent(typeof(Button))]
public class OpenDemoScene : MonoBehaviour
{
    public void Awake()
    {
        GetComponent<Button>().onClick.AddListener(OnButtonClicked);
    }

    private void OnButtonClicked()
    {
        SceneManager.LoadScene("Battlefield", LoadSceneMode.Single);
    }
}
