//----------------------------------------------
//            Realistic Car Controller
//
// Copyright © 2014 - 2020 BoneCracker Games
// http://www.bonecrackergames.com
// Buğra Özdoğanlar
//
//----------------------------------------------

using UnityEngine;
using UnityEditor;

public class ExportPackage{
	[MenuItem ("Export/MyExport")]
	static void Export(){
		
//		AssetDatabase.ExportPackage (AssetDatabase.GetAllAssetPaths(),PlayerSettings.productName + ".unitypackage",ExportPackageOptions.Interactive | ExportPackageOptions.Recurse | ExportPackageOptions.IncludeDependencies | ExportPackageOptions.IncludeLibraryAssets);

		string[] projectContent = new string[] {"ProjectSettings/TagManager.asset","ProjectSettings/InputManager.asset"};
		AssetDatabase.ExportPackage(projectContent, "RCC_ProjectSettings.unitypackage",ExportPackageOptions.Interactive | ExportPackageOptions.Recurse |ExportPackageOptions.IncludeDependencies);
		Debug.Log("Project Exported");

	}
}