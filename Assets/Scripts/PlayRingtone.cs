using UnityEngine;

public class PlayRingtone : MonoBehaviour
{

    [SerializeField] private AudioSource source;
   
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (source.isPlaying)
            {
                source.Stop();
            }
            else
            {
                source.Play();
            }
        }
    }
}
