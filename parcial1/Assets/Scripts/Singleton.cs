using UnityEngine;

public class Singleton<T> : MonoBehaviour where T : MonoBehaviour
{
    private static T _instance;
    private static readonly object _lock = new object();

    public static T Instance
    {
        get
        {
            lock (_lock)
            {
                if (_instance == null)
                {
                    // Busca si ya existe una instancia en la escena
                    _instance = (T)FindObjectOfType(typeof(T));

                    if (_instance == null)
                    {
                        // Si no existe, crea un nuevo GameObject para contenerlo
                        GameObject singletonObject = new GameObject();
                        _instance = singletonObject.AddComponent<T>();
                        singletonObject.name = typeof(T).ToString() + " (Singleton)";

                        // Opcional: Hacerlo persistente entre escenas
                        // DontDestroyOnLoad(singletonObject);
                    }
                }
                return _instance;
            }
        }
    }

    protected virtual void Awake()
    {
        if (_instance == null)
        {
            _instance = this as T;
            // Descomenta la siguiente línea si quieres que todos tus singletons 
            // sobrevivan al cambio de escenas por defecto.
            // DontDestroyOnLoad(gameObject);
        }
        else if (_instance != this)
        {
            Debug.LogWarning($"[Singleton] Instancia duplicada de {typeof(T)} destruida en {gameObject.name}");
            Destroy(gameObject);
        }
    }
}