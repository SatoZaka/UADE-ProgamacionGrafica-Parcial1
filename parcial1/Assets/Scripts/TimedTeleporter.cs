using UnityEngine;
using UnityEngine.Events;

public class TimedTeleporter : MonoBehaviour
{
    [Header("Configuración")]
    [Tooltip("Tiempo en segundos que el jugador debe permanecer dentro")]
    public float timeRequired = 3.0f;
    
    [Tooltip("Tag del objeto que puede activar la transición")]
    public string targetTag = "Player";

    [Header("Eventos Visuales (Opcional)")]
    public UnityEvent<float> OnTimerUpdate; // Útil para barras de carga

    private float timer = 0f;
    private bool isInside = false;

    private void Update()
    {
        if (isInside)
        {
            timer += Time.deltaTime;

            // Invocamos un evento por si quieres conectar una barra de progreso UI
            OnTimerUpdate?.Invoke(timer / timeRequired);

            if (timer >= timeRequired)
            {
                ExecuteTransition();
            }
        }
    }

    private void ExecuteTransition()
    {
        isInside = false; // Evita múltiples ejecuciones
        timer = 0f;
        
        // Llamada al Singleton que creamos anteriormente
        if (SceneController.Instance != null)
        {
            SceneController.Instance.GoToNextScene();
        }
        else
        {
            Debug.LogError("No se encontró una instancia de SceneController en la escena.");
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(targetTag))
        {
            isInside = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(targetTag))
        {
            isInside = false;
            timer = 0f; // Reiniciamos el tiempo si sale
            OnTimerUpdate?.Invoke(0f);
        }
    }
}