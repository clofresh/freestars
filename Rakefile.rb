task :build do
    sh "zip -r ../${PWD##*/}.love *"
end
