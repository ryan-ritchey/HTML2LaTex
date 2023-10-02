
%{
/**************************************************************************
* Ryan Ritchey | MVV672 | M2.2.3 Programming Assignment | Compiler Construction
*************************************************************************/
    
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int list_type;

%}

%option       noyywrap nounput yylineno
%x            COMMENT PARA PRE OL UL LI

%%

"<h1>"[^<]*"</h1>" {
    /**************************************************************************
     * Matched an HTML H1 header so print it out as a LateX section title.
     * The beginning and ending tags need to be stripped off before the
     * title can be formatted in LateX.
     *************************************************************************/
    yytext[yyleng-5] = 0;
    printf( "\\section{%s}", yytext+4 );
}

"<h2>"[^<]*"</h2>" {
    /**************************************************************************
     * Matched an HTML H2 header so print it out as a LateX section title.
     * The beginning and ending tags need to be stripped off before the
     * title can be formatted in LateX.
     *************************************************************************/
    yytext[yyleng-5] = 0;
    printf( "\\subsection{%s}", yytext+4 );
}

"<h3>"[^<]*"</h3>" {
    /**************************************************************************
     * Matched an HTML H3 header so print it out as a LateX section title.
     * The beginning and ending tags need to be stripped off before the
     * title can be formatted in LateX.
     *************************************************************************/
    yytext[yyleng-5] = 0;
    printf( "\\subsubsection{%s}", yytext+4 );
}

"<!--" {
    /**************************************************************************
     * Matched an HTML comment so print it out as a LateX comment. The
     * beginning and ending tags are stripped off before the LateX comment
     * is emitted.
     *************************************************************************/
    printf( "%% " );
    BEGIN COMMENT;
}

[ \t\n\r]+ {
    /**************************************************************************
     * Matched some whitespace that is not inside of an HTML tag. We
     * just ignore the whitespace.
     *************************************************************************/
}

. {
    /**************************************************************************
     * Matched something that we did not expect to see. Issue an error and
     * exit the program with a failure code.
     *************************************************************************/
    fprintf( stderr, "Unexpected input at line %d: '%s'\n", yylineno, yytext );
    exit( 1 );
}

<COMMENT>"-->" {
    /**************************************************************************
     * Matched an HTML end comment while parsing an HTML comment. Print out
     * a new line and resume normal parsing.
     *************************************************************************/
    printf( "\n" );
    BEGIN 0;
}

<COMMENT>[\n](\r)? {
    /**************************************************************************
     * Matched a newline while parsing an HTML comment. Print out a new
     * line making sure to mark the next line as a comment as well.
     *************************************************************************/
    printf( "\n%% " );
}

<COMMENT>[ \t] {
    /**************************************************************************
     * Matched some white space while parsing an HTML comment. Print out
     * the white space as is.
     *************************************************************************/
    printf( "%s", yytext );
}

<COMMENT>. {
    /**************************************************************************
     * Matched any other text while parsing an HTML comment. Print out
     * the text as is.
     *************************************************************************/
    printf( "%s", yytext );
}

"<pre>"[^<]*"</pre>" {
    /**************************************************************************
     * Matched an HTML pre-formatted paragraph so print it out as a LaTeX
     * We need to use verbatim becuase it is preformatted.
     *************************************************************************/
     yytext[yyleng-6] = 0;
     printf( "\\begin{verbatim}%s\\end{verbatim}\n", yytext+5 );
}

"<p>" {
    /**************************************************************************
    * Matched the beginning tag of an HTML pararaph and swith to the PARA state condition.
    * Dont match the </p> due to there being tags we need to operate on in the paragraph. 
    **************************************************************************/
    BEGIN PARA;
}

<PARA>[^<]+/"<" {
    /**************************************************************************
    * Matched text inside a paragraph and print it.
    **************************************************************************/
    printf("%s", yytext);
}

<PARA>"</p>" {
    /**************************************************************************
    * After reading throught the paragraph, we match the end of the paragraph tag.
    **************************************************************************/
    printf("\n");
    BEGIN 0;
}

<LI>[^<]+/"<" {
    /**************************************************************************
     * Matched text inside of a list and print it.
     *************************************************************************/
    printf("%s", yytext);
}

<LI>"</li>" {
    /**************************************************************************
     * Match the closing of a list tag. If the list is a UL, switch to the UL state.
     * If the list is an OL, switch to the OL state. (Determined by list_type either being 1 or 0)
     *************************************************************************/
    printf("\n");
    if (list_type == 1)
        BEGIN UL;
    else
        BEGIN OL;
}

"<ol>" {
    /**************************************************************************
     * Matched an ordered list, print enumerate because it is an ordred list. Finally switch to the OL state.
     * We dont read the </ol> tag becuase there are other tags that we need to operate on.
     *************************************************************************/
    printf("\\begin{enumerate}\n");
    BEGIN OL;
}

<OL>[^<]+/"<" {
    /**************************************************************************
     * Matched ol text.
     *************************************************************************/
}

<OL>"</ol>" {
    /**************************************************************************
     * Match an odered list clising tag. Print the end of enumerate. Go back to orgional state.
     *************************************************************************/
    printf("\\end{enumerate}\n");
    BEGIN 0;
}

<OL>"<li>" {
    /**************************************************************************
     * Match an item that belongs to an ordered list.
     *************************************************************************/
    printf("%4s%s", " ", "\\item ");
    list_type = 0;
    BEGIN LI;
}

"<ul>" {
    /**************************************************************************
     * Matched an unordred list. Print itemize. Switch to the UL state. 
     * Dont find the ending tag becuase there are other tags that need to be handled.
     *************************************************************************/
    printf("\\begin{itemize}\n");
    BEGIN UL;
}

<UL>[^<]+/"<" {
    /**************************************************************************
     * Match text inside an unordered list.
     *************************************************************************/
}

<UL>"</ul>" {
    /**************************************************************************
     * Matched the end tag for an UL. Print the end of itemize. Switch back to the origional state.
     *************************************************************************/
    printf("\\end{itemize}\n");
    BEGIN 0;
}


<UL>"<li>" {
    /**************************************************************************
     * Matched a list tag in an UL.
     *************************************************************************/
    printf("%4s%s", " ", "\\item ");
    list_type = 1;
    BEGIN LI;
}

<PARA,OL,UL,LI>"<small>"[^<]+"</small>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the small tag.
     * Print the text in the small tag.
     *************************************************************************/
    const int tag_len = strlen("small");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "scriptsize", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<big>"[^<]+"</big>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the big tag.
     * Print the text in the big tag.
     *************************************************************************/
    const int tag_len = strlen("big");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "Large", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<b>"[^<]+"</b>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the bold tag.
     * Print the text in the <b> tag.
     *************************************************************************/
    const int tag_len = strlen("b");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "textbf", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<i>"[^<]+"</i>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the i tag.
     * Print the text in the <i> tag.
     *************************************************************************/

    const int tag_len = strlen("i");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "textit", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<strong>"[^<]+"</strong>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the strong tag.
     * Print the text in the <strong> tag.
     *************************************************************************/
    const int tag_len = strlen("strong");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "textmd", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<em>"[^<]+"</em>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the em tag.
     * Print the text in the <em> tag.
     *************************************************************************/
    const int tag_len = strlen("em");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "emph", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<sup>"[^<]+"</sup"> {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the sup tag.
     * Print the text in the sup tag.
     *************************************************************************/
    
    const int tag_len = strlen("sup");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "textsuperscript", yytext + tag_len + 2);
}

<PARA,OL,UL,LI>"<sub>"[^<]+"</sub>" {
    /**************************************************************************
     * While in the PARA, OL, UL, or LI state, match the sub tag.
     * Print the text in the <sub> tag.
     *************************************************************************/
    const int tag_len = strlen("sub");

    yytext[yyleng - tag_len - 3] = 0;
    printf("{\\%s %s}", "textsubscript", yytext + tag_len + 2);
}

%%

/**************************************************************************
 * The main function for the HTML to LateX converter. Here we do three
 * things:
 *  1. Print out the LateX document header.
 *  2. Invoke the lexer to print out the LateX document
 *  3. Print out the LateX footer.
 *************************************************************************/
int main( int argc, const char *argv[] ) {
    printf( "\\documentclass[12pt]{article}\n" );
    printf( "\\usepackage{fixltx2e}\n" );
    printf( "\n" );
    printf( "\\setlength{\\parindent}{0.0in}\n" );
    printf( "\\setlength{\\parskip}{0.125in}\n" );
    printf( "\n\n" );
    printf( "\\begin{document}\n" );
    yylex();
    printf( "\\end{document}\n" );
    return 0;
}
