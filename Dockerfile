# build runtime image
FROM microsoft/aspnetcore:2.0.9
WORKDIR /app
COPY . /app
CMD ["dotnet", "LaRepublicaCDN.dll"]
#ENTRYPOINT ["dotnet", "LaRepublicaCDN.dll"]
