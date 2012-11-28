/* Given some text, make it into only lowercase a-z and space.  Also,
   compress consecutive white space into a single character. */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

main(){

  int ch,prev_space;
  
  prev_space=0;
  while (EOF!=(ch=fgetc(stdin))){
    if (isalpha(ch)){
      prev_space=0;
      ch=tolower(ch);
      printf("%c",ch);
    }
    else if (isspace(ch)){
      if (prev_space==0) {
	  printf(" ");
	}
      prev_space=1;
    }
  }
}

  
