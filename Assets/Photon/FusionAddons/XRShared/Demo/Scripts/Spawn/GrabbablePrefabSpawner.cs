using Fusion.XR.Shared.Grabbing;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Fusion.XRShared.Demo
{
    /**
     * Spawns a prefab when the spawnerGrabbableReference (a Grabbable - no need of a NetworkGrabble or any network object) is far enough
     * 
     * If the prefab contains a NetworkObject, uses the runner to spawn it properly.
     */

    public class GrabbablePrefabSpawner : MonoBehaviour
    {
        public GameObject prefab;
        [SerializeField]
        NetworkRunner runner;
        public Grabbable spawnerGrabbableReference;
        [SerializeField]
        float liberationDistance = .1f;

        Pose defaultPosition;

        [Header("Feedback")]
        [SerializeField] private AudioSource audioSource;
        [SerializeField] private AudioClip audioClip;

        protected virtual void Awake()
        {
            if (runner == null) runner = FindObjectOfType<NetworkRunner>(true);
            if (runner == null)
            {
                Debug.LogError("A NetworkRunner is required");
            }
            if (spawnerGrabbableReference == null)
            {
                spawnerGrabbableReference = GetComponentInChildren<Grabbable>();
            }

            if (spawnerGrabbableReference)
            {
                defaultPosition.position = spawnerGrabbableReference.transform.localPosition;
                defaultPosition.rotation = spawnerGrabbableReference.transform.localRotation;
                spawnerGrabbableReference.onUngrab.AddListener(OnSpawnerUngrab);
            }
            else
            {
                Debug.LogError("A spawnerGrabbableObject, containing a Grabbable component, is required");
            }

            if (audioSource == null)
                audioSource = GetComponentInParent<AudioSource>();
            if (audioSource == null)
                Debug.LogError("AudioSource not found");
        }

        private void OnSpawnerUngrab()
        {
            if (Vector3.Distance(transform.position, spawnerGrabbableReference.transform.position) > liberationDistance)
            {
                Spawn();
            }
            ResetReferencePose();
        }

        public virtual GameObject Spawn()
        {
            GameObject spawnedObject = null;

            if (runner == null || runner.IsRunning == false) return null;
            if (prefab.GetComponentInChildren<NetworkObject>())
            {
                var no = runner.Spawn(prefab, spawnerGrabbableReference.transform.position, spawnerGrabbableReference.transform.rotation);
                spawnedObject = no.gameObject;
            }
            else
            {
                spawnedObject = GameObject.Instantiate(prefab, spawnerGrabbableReference.transform.position, spawnerGrabbableReference.transform.rotation);
            }
            PlayAudioFeeback();
            return spawnedObject;
        }

        protected virtual void ResetReferencePose()
        {
            spawnerGrabbableReference.transform.localPosition = defaultPosition.position;
            spawnerGrabbableReference.transform.localRotation = defaultPosition.rotation;
        }

        protected void PlayAudioFeeback()
        {
            if (audioSource && audioClip && audioSource.isPlaying == false)
            {
                audioSource.clip = audioClip;
                audioSource.Play();
            }
        }

    }

}
