using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RCC_Teleporter : MonoBehaviour{

	public Transform spawnPoint;
	
	void OnTriggerEnter(Collider col){

		RCC_CarControllerV3 carController = col.gameObject.GetComponentInParent<RCC_CarControllerV3> ();

		if (!carController)
			return;

		RCC.Transport (spawnPoint.position, spawnPoint.rotation);
		
	}

}
