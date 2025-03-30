# Azure Infrastructure-as-Code

### Design Diagram
<!--insert image here-->

### Docker
First, make a Dockerfile.
(Check the Dockerfile in this repo)

After creating the Dockerfile, navigate to the directory where it is located, and build the image by running:
```
docker build -t bvde-assignment2-flasktask .
```
![build](https://i.imgur.com/e9NhkiA.png)


### Azure container registry
Now, you will create a container registry on Azure and push the image.

First, log in using
``` az login ```
and choose an account and subscription.

Next, create a resource group with the following command:
```
az group create --name bvde-Ass2ResourceGroup --location eastus
```
![resourcegroup](https://i.imgur.com/q2DOw2m.png)


Now, you need to create the acr using Bicep (see createACR.bicep in this repo). Do this by running the following command:
```
az deployment group create --resource-group bvde-Ass2ResourceGroup --template-file createACR.bicep --parameters acrName=bvdeass2containerregistry
```
When this is done, somewhere near the middle of the output, you will see "outputs" and under it "loginServer" (see image). Note the value there (it ends in ".azurecr.io"), because you will need it later.

![loginserver](https://i.imgur.com/HFUB6Up.png)


Next, log in to the acr with:
```
az acr login --name bvdeass2containerregistry
```
![login](https://i.imgur.com/8Lfapin.png)

### Docker, part 2
Now, you need to tag the docker image with the full name of the registry.
You need the loginServer, which you noted earlier. If you haven't, you can check it by running:
```
az acr show --name bvdeass2containerregistry --query loginServer
```
![loginservershow](https://i.imgur.com/tsl9wbd.png)

Now, run the following command (part of it is the result from before):
```
docker tag bvde-assignment2-flasktask bvdeass2containerregistry.azurecr.io/bvde-assignment2-flasktask:latest
```

Now push the image
```
docker push bvdeass2containerregistry.azurecr.io/bvde-assignment2-flasktask:latest
```
![dockerpush](https://i.imgur.com/OO5GLUT.png)
If you want to check if the image was pushed to the registry correctly, you can run:
```
az acr repository list --name bvdeass2containerregistry
```
![repo](https://i.imgur.com/sdhavBJ.png)
If this returns the name of the image, everything went well.

### Creating the token
Sadly, the next part is a little tricky because I couldn't get secure storage working for the token password.
To create the token, run:
```
az acr token credential generate --name pullToken --registry bvdeass2containerregistry --resource-group bvde-Ass2ResourceGroup --expiration-in-days 30
````
In the output, copy the value of the first password (the long string). Then go to your bicep file, for me this is deployContainer.bicep
##### I made 2 bicep files instead of 1, to have the creation and deployment separated, you can do it with 1 bicep file aswell.

In the containerGroup, look for "imageRegistryCredentials", and under it for "password" (see image).
Remove the value there and replace it with what you copied.
![tokenpassword](https://i.imgur.com/RlnW2vW.png)

Now, you need to commit and push that change to GitHub.
The commit will be fine, but when you try to push, it will block it because there is a password in plain text (because you just put it there).
In the error message there will be a url you need to go to to unblock it.
##### not the first url you see (the one with "docs" in it), but the second one, something like https://github.com/<yourGitHubUsername>/<repositoryName>/security/secret-scanning/unblock-secret/<longString>

Since this is a small project that will not be released (expect on this github repo), you can choose "It's used in tests". No harm can be done with this application, at least not when it is in this form.

When you expand on this project and more data gets saved or something else, there could be harm if someone finds the password. In that case, of course you preferably fix it, but if you really need to push changes, you can choose "I'll fix it later". This alerts admins of a possible security risk, so no one can forget about this.

### Deploying the container
Finally, when the push worked correctly, run:
```
az deployment group create --resource-group bvde-Ass2ResourceGroup --template-file deployContainer.bicep
```

Now, similarly to how you had to look for outputs for the login server earlier, this time you need to look for the IP address. The word "outputs" will be somewhere a little above the middle of the command's output.

Look for "ipAddress", then type the address in your browser's search bar. It should work, but if it doesn't, try typing "http://<ipAddres>:80".

If you cant find it, you can also go to your Azure portal and look for the container instance. Click on it and it will show you the IP address somewhere (see image).
![azureportal](https://i.imgur.com/ZJuDSZm.png)
