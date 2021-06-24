using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RCC_DetachablePart : MonoBehaviour{

	public Transform COM;
	private Rigidbody rigid;

	public bool lockAtStart = true;
	public float strength = 100f;

	[System.Serializable]
	private class DetachableJoint{

		public ConfigurableJoint joint;

		internal ConfigurableJointMotion jointMotionAngularX;
		internal ConfigurableJointMotion jointMotionAngularY;
		internal ConfigurableJointMotion jointMotionAngularZ;

		internal ConfigurableJointMotion jointMotionX;
		internal ConfigurableJointMotion jointMotionY;
		internal ConfigurableJointMotion jointMotionZ;

		public int strength = 25000;		//	Strength of the part.

	}

	private DetachableJoint detachableJoint = new DetachableJoint();

    void Start(){

		rigid = GetComponent<Rigidbody> ();

		if(COM)
			rigid.centerOfMass = transform.InverseTransformPoint(COM.transform.position);

		ConfigurableJoint joint = gameObject.GetComponent<ConfigurableJoint> ();

		if (joint){
			
			detachableJoint.joint = joint;

		}else{
			
			Debug.LogWarning ("Configurable Joint not found for " + gameObject.name + "!");
			enabled = false;
			return;

		}

		if(lockAtStart)
			LockParts ();
        
    }

	/// <summary>
	/// Locks the parts.
	/// </summary>
	private void LockParts(){

		//	Getting default settings of the part.
		detachableJoint.jointMotionAngularX = detachableJoint.joint.angularXMotion;
		detachableJoint.jointMotionAngularY = detachableJoint.joint.angularYMotion;
		detachableJoint.jointMotionAngularZ = detachableJoint.joint.angularZMotion;

		detachableJoint.jointMotionX = detachableJoint.joint.xMotion;
		detachableJoint.jointMotionY = detachableJoint.joint.yMotion;
		detachableJoint.jointMotionZ = detachableJoint.joint.zMotion;

		//	Locking the part.
		detachableJoint.joint.angularXMotion = ConfigurableJointMotion.Locked;
		detachableJoint.joint.angularYMotion = ConfigurableJointMotion.Locked;
		detachableJoint.joint.angularZMotion = ConfigurableJointMotion.Locked;

		detachableJoint.joint.xMotion = ConfigurableJointMotion.Locked;
		detachableJoint.joint.yMotion = ConfigurableJointMotion.Locked;
		detachableJoint.joint.zMotion = ConfigurableJointMotion.Locked;

//		detachableJoint.joint.breakForce = detachableJoint.strength;
//		detachableJoint.joint.breakTorque = detachableJoint.strength;

	}

	/// <summary>
	/// Damages the parts.
	/// </summary>
	private void DamageParts(){

		// Unlocking the parts and set their joint configuration to default.

		if (detachableJoint.joint) {

			detachableJoint.joint.angularXMotion = detachableJoint.jointMotionAngularX;
			detachableJoint.joint.angularYMotion = detachableJoint.jointMotionAngularY;
			detachableJoint.joint.angularZMotion = detachableJoint.jointMotionAngularZ;

			detachableJoint.joint.xMotion = detachableJoint.jointMotionX;
			detachableJoint.joint.yMotion = detachableJoint.jointMotionY;
			detachableJoint.joint.zMotion = detachableJoint.jointMotionZ;

		}

	}

	void OnCollisionEnter(Collision col){

		strength -= col.relativeVelocity.magnitude * 100f;
//		DamageParts ();		//	Damage parts.

	}

}
