# Azure Infrastructure-as-Code

### Design Diagram
<!--insert image here-->

### Docker
First, make a Dockerfile.
(Check the Dockerfile in this repo.)

After creating the Dockerfile, navigate to the directory where it is located, and build the image by running:
```
docker build -t bvde-assignment2-flasktask .
```
<!--insert image here-->


### Azure container registry
Now, you will create a container registry on Azure and push the image.

First, log in using
``` az login ```
and choose an account and subscription

Now, create a resource group with the following command:
```
az group create --name bvde-Ass2ResourceGroup --location eastus
```
<!--insert image here-->

Next, you need to create the acr using Bicep (see createACR.bicep in this repo). Do this by running the following command:
```
az deployment group create --resource-group bvde-Ass2ResourceGroup --template-file createACR.bicep --parameters acrName=bvdeass2containerregistry
```
##### This might take a little while.

Somewhere near the middle of the output, you will see "outputs" and under it "loginServer". Note the value there (it ends in ".azurecr.io"), because you will need it later.

<!--insert image here-->

Next, log in to the acr with:
```
az acr login --name bvdeass2containerregistry
```
<!--insert image here-->

### Docker, part 2
Now, you need to tag the docker image with the full name of the registry.
You need the loginServer, which you noted earlier. If you haven't, you can check it by running:
```
az acr show --name bvdeass2containerregistry --query loginServer
```
<!--insert image here-->

The result is needed in the next command:
```
docker tag bvde-assignment2-flasktask bvdeass2containerregistry.azurecr.io/bvde-assignment2-flasktask:latest
```

Now push the image
```
docker push bvdeass2containerregistry.azurecr.io/bvde-assignment2-flasktask:latest
```
<!--insert image here-->
If you want to check if the image was pushed to the registry correctly, you can run:
```
az acr repository list --name bvdeass2containerregistry
```
<!--insert image here-->
If this returns the name of the image, everything went well.

### Creating token
Sadly, the next part is a little tricky because I couldn't get secure storage working for the token password.
To create the token, run:
```
az acr token credential generate --name pullToken --registry bvdeass2containerregistry --resource-group bvde-Ass2ResourceGroup --expiration-in-days 30
````
In the output, copy the value of the first password (the long string).
Then go to your bicep file, for me this is deployContainer.bicep, I made 2 bicep files instead of 1 to have the creation and deployment separated, you can do it with 1 bicep file aswell.
In the containerGroup, look for "imageRegistryCredentials", and under it for "password".
Remove the value there and replace it with what you copied.
<!--insert image here-->

Now, you need to commit and push that change to GitHub.
The commit will be fine, but when you try to push, it will block it because there is a password in plain text (because you just put it there).
In the error message there will be a url you need to go to to unblock it.
