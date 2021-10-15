- **##### clone_module.sh**

O script [clone_module.sh](https://github.com/d3estudio/d3-lib/blob/master/.d3-lib/clone_module.sh) realiza a clonagem de repositórios de maneira automática, apartir de um arquivo [.config](https://github.com/d3estudio/d3-lib/blob/master/.config) na raiz do repositório, arquivo o qual recebe todos os repositórios que serão clonados e algumas configurações, como a branch de clonagem, o commit especifico(caso seja requerido, caso não seja informado ele clona o ultimo) e o caminho que será feito o download do repositório. Com essas configurações setadas, já está pronto para utilizar o script de clone.

> .config -> O arquivo .config possui algumas particularidades/padrões que devem ser seguidos para o total funcionamento do mesmo, como a separação de um elemento para o outro deve ser feita pela tecla 'ENTER' que é o mesmo que uma quebra de linha, pois é dessa forma que o script faz a separação dos elementos do array.Outro ponto é tentar manter as configuações sempre alinhadas com as tag  < repoUrl > e , para separar as sub-propriedades do array,e também para deixar as configurações mais visiveis para qualquer pessoa.

> OBS: A clonagem feita pelo clone_module.sh utiliza SSH, então é necessario estar com sua ssh-key configurada na maquina caso não saiba como fazer tal configuração [clique aqui](https://github.com/d3estudio/d3-lib/blob/master/.d3-lib/ssh-login.md) e leia as instruções.

- **##### checkout_module.sh**

O script [checkout_module.sh](https://github.com/d3estudio/d3-lib/blob/master/.d3-lib/checkout_module.sh) vai te auxiliar a fazer deploy de imagem para Amazon ECR. É um modúlo o qual verifica os repositórios que foram clonados de maneira correta, e em seguida estabelece uma comunicação com amazon para verificar se essas imagens que está querendo mandar já existem no repositório ECR, caso exista ele simplemente ignore e não sobre a imagem para economizar tempo e espaço de armazenamento, caso não exista ele vai acionar o aws_module.sh.

> OBS: O checkout_module.sh é ideal para fazer validações durante o deploy de aplicações.Caso seja necessario alguma funcionalidade especifica de validação, esse é o cara certo:)

- **##### aws_module.sh**

O script [aws_module.sh](https://github.com/d3estudio/d3-lib/blob/master/.d3-lib/aws_module.sh) tem funcionalidades ligadas a comunicação com serviços AWS, tanto na checagem se imagem existe ou não repositório da amazon, como também na parte de enviar essas imagens buildadas para o repositório na amazon.

> OBS: o  aws_module.sh possui funcionalidade default, porém, você não precisa ficar preso as features padrão, caso precise de uma solução especifica para outro serivço amazon, pode ficar a vontade para fazer a implementação no [aws_module.sh](https://github.com/d3estudio/d3-lib/blob/master/.d3-lib/aws_module.sh).

- **##### rancher_modules.sh**

O script [rancher_module.sh](https://github.com/d3estudio/d3-lib/blob/master/.d3-lib/rancher_module.sh) tem a resposanbilidade de realizar a comunicação com o [rancher](https://rancher.com/), para fazer deploy das imagens que o aws_module.sh.

> OBS: O rancher_module.sh está 100% aberto a receber novas features(funcionalidade especificas que você deseja utilizar) basta criar a função dentro do modúlo e exportar ele para onde quiser utilizar.