using UnityEngine;

public class CameraLinearLook : MonoBehaviour
{
    [Header("Movimiento Lineal")]
    public Transform pointA;
    public Transform pointB;
    public float speed = 5f;

    [Header("Rotación (Mouse Look)")]
    public float sensitivity = 2f;
    public float minY = -60f;
    public float maxY = 60f;

    private float rotationX = 0f;
    private float rotationY = 0f;

    void Start()
    {
        // Inicializar la posición en el punto A
        if (pointA != null)
        {
            transform.position = pointA.position;
        }

        // Inicializar rotaciones actuales para evitar saltos
        Vector3 currentRotation = transform.localEulerAngles;
        rotationX = currentRotation.y;
        rotationY = -currentRotation.x;

        // Opcional: Bloquear el cursor para una mejor experiencia de "Free Look"
        // Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        HandleRotation();
        HandleMovement();
    }

    private void HandleRotation()
    {
        // Obtener entrada del mouse
        rotationX += Input.GetAxis("Mouse X") * sensitivity;
        rotationY += Input.GetAxis("Mouse Y") * sensitivity;

        // Limitar la rotación vertical (pitch)
        rotationY = Mathf.Clamp(rotationY, minY, maxY);

        // Aplicar la rotación (invertimos Y para que el movimiento sea natural)
        transform.localRotation = Quaternion.Euler(-rotationY, rotationX, 0);
    }

    private void HandleMovement()
    {
        if (pointA == null || pointB == null) return;

        // Mover hacia el punto B
        transform.position = Vector3.MoveTowards(
            transform.position, 
            pointB.position, 
            speed * Time.deltaTime
        );

        // Si la distancia es casi cero, teletransportar al punto A
        if (Vector3.Distance(transform.position, pointB.position) < 0.001f)
        {
            transform.position = pointA.position;
        }
    }
}
