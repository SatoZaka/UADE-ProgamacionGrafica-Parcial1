using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Events;

public class SceneController : Singleton<SceneController>
{
    [Header("Configuración de Escenas")]
    [Tooltip("Lista los nombres de las escenas tal cual aparecen en Build Settings")]
    public List<string> sceneNames;

    [Header("Referencias")]
    public Animator transitionAnimator;
    [Tooltip("Nombre del trigger en el Animator para iniciar la desaparición")]
    public string fadeOutTrigger = "StartTransition";
    public TextMeshProUGUI sceneNameText;

    [Header("Eventos")]
    public UnityEvent OnLoadStarted;
    public UnityEvent OnLoadFinished;

    private bool isTransitioning = false;

    void OnEnable()
    {
        DontDestroyOnLoad(transitionAnimator.gameObject);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.F2))
        {
            GoToNextScene();
        }
    }


    [ContextMenu("Go To Next Scene")]
    public void GoToNextScene()
    {
        int nextIndex = SceneManager.GetActiveScene().buildIndex + 1;
        if (nextIndex < SceneManager.sceneCountInBuildSettings)
        {
            StartCoroutine(LoadSceneAsync(nextIndex));
        }
        else
        {
            Debug.LogWarning("No hay más escenas en el Build Settings.");
        }
    }

    public void GoToScene(int sceneIndex)
    {
        if (!isTransitioning)
        {
            StartCoroutine(LoadSceneAsync(sceneIndex));
        }
    }

    private IEnumerator LoadSceneAsync(int index)
    {
        isTransitioning = true;
        OnLoadStarted?.Invoke();

        // 1. Iniciar la animación de transición
        if (transitionAnimator != null)
        {
            transitionAnimator.SetTrigger(fadeOutTrigger);
            
            // Esperar a que la animación termine (ajustar según duración del clip)
            // Si no quieres hardcodear el tiempo, puedes usar:
            // yield return new WaitForSeconds(transitionAnimator.GetCurrentAnimatorStateInfo(0).length);
            yield return new WaitForSeconds(1f); 
        }

        // 2. Cargar la escena asincrónicamente
        AsyncOperation operation = SceneManager.LoadSceneAsync(index);
        
        // Evita que la escena se active inmediatamente si necesitas control total
        // operation.allowSceneActivation = false; 

        while (!operation.isDone)
        {
            yield return null;
        }

        OnLoadFinished?.Invoke();
        isTransitioning = false;
        
        sceneNameText.text = sceneNames[index];
    }
}