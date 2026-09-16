using UnityEngine;

public class OrbitCamera : MonoBehaviour
{
    [Header("Configuración de Objetivo")]
    public Transform target; // El objeto al que orbitaremos
    public float distance = 10.0f; // Radio de la esfera
    public float minDistance = 2f;
    public float maxDistance = 30f;

    [Header("Configuración de Movimiento")]
    public float sensitivity = 5.0f;
    public float zoomSensitivity = 2.0f;
    public float keyboardRotationSpeed = 80.0f;

    [Header("Límites")]
    public float yMinLimit = -20f; // Límite inferior para no pasar por debajo del suelo
    public float yMaxLimit = 80f;  // Límite superior para evitar el "gimbal lock"

    private float x = 0.0f;
    private float y = 0.0f;

    void Start()
    {
        Vector3 angles = transform.eulerAngles;
        x = angles.y;
        y = angles.x;

        // Si no hay objetivo, intentamos no romper el script
        if (target == null)
        {
            Debug.LogWarning("OrbitCamera: No se ha asignado un Target en el Inspector.");
        }
    }

    void LateUpdate()
    {
        if (target == null) return;

        // --- 1. ROTACIÓN (Mouse y Teclado) ---
        
        // Entrada de Mouse (Click izquierdo presionado)
        if (Input.GetMouseButton(0))
        {
            x += Input.GetAxis("Mouse X") * sensitivity;
            y -= Input.GetAxis("Mouse Y") * sensitivity;
        }

        // Entrada de Teclado (WASD)
        x += Input.GetAxis("Horizontal") * keyboardRotationSpeed * Time.deltaTime;
        y -= Input.GetAxis("Vertical") * keyboardRotationSpeed * Time.deltaTime;

        // Limitar la rotación vertical para evitar que la cámara se de vuelta
        y = ClampAngle(y, yMinLimit, yMaxLimit);

        // --- 2. ZOOM (+, -, Rueda del Mouse) ---
        
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        distance -= scroll * zoomSensitivity * 5;

        if (Input.GetKey(KeyCode.Plus) || Input.GetKey(KeyCode.KeypadPlus))
            distance -= zoomSensitivity * Time.deltaTime * 10f;
        
        if (Input.GetKey(KeyCode.Minus) || Input.GetKey(KeyCode.KeypadMinus))
            distance += zoomSensitivity * Time.deltaTime * 10f;

        distance = Mathf.Clamp(distance, minDistance, maxDistance);

        // --- 3. APLICAR POSICIÓN Y ROTACIÓN ---

        Quaternion rotation = Quaternion.Euler(y, x, 0);
        
        // Calculamos la posición en la superficie de la esfera
        Vector3 negDistance = new Vector3(0.0f, 0.0f, -distance);
        Vector3 position = rotation * negDistance + target.position;

        transform.rotation = rotation;
        transform.position = position;
    }

    // Utilidad para normalizar y limitar ángulos
    private float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360f) angle += 360f;
        if (angle > 360f) angle -= 360f;
        return Mathf.Clamp(angle, min, max);
    }
}