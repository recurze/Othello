#include <iostream>
#include <stdlib.h>

#define rep(i,n)        for(int i=0; i<n; i++)

const int N=8;

int grid[N][N], x, y, p;

void print();                   // prints the whole board
bool move_exists();             // checks if the current player can make a move.
bool valid(int, int);           // checks if i,j is a valid move
    bool lvalid(int, int);
    bool rvalid(int, int);
    bool uvalid(int, int);
    bool dvalid(int, int);
    bool ulvalid(int, int);
    bool urvalid(int, int);
    bool dlvalid(int, int);
    bool drvalid(int, int);

void makemove();                // makes move x,y (global)
    void lmove();
    void rmove();
    void umove();
    void dmove();
    void ulmove();
    void urmove();
    void dlmove();
    void drmove();

int winner();                   // returns the winner 0 for draw.

bool inboard(int i, int j){
    return i>-1 && j>-1 && i<N && j<N;
}

int main(int argc, char const *argv[]) {
    grid[3][3]=grid[4][4]=1;
    grid[3][4]=grid[4][3]=2;
    print();
    bool flag=0;
    p=2;
    while(1){
        if(!move_exists()){
            if(flag) break;
            flag=1;
            p=1+(p&1);
            continue;
        }
        std::cout<<"Player "<<p<<"("<<(p==1?"White):":"Black):");
        std::cin>>x>>y;
        if(!inboard(x, y) || !valid(x, y))
            continue;
        flag=0;
        makemove();
        p=1+(p&1);
        print();
    }
    int win=winner();
    std::cout<<"Winner: Player"<<win<<(win==1?": White":": Black");
    return 0;
}

void print(){
    std::cout<<"\033c   ";
    rep(i,N){
        std::cout<<i<<' ';
    }
    std::cout<<'\n';
    rep(i,N){
        std::cout<<i<<"  ";
        rep(j,N){
            if(grid[i][j]==1){
                std::cout<<"\033[4;47m \33[0m";
            } else if(grid[i][j]==2){
                std::cout<<"\033[4;40m \33[0m";
            } else {
                std::cout<<"\033[4;41m \33[0m";
            }
            std::cout<<"|";
        }
        std::cout<<"\n";
    }
}

bool move_exists(){
    rep(i,N){
        rep(j,N){
            if(!grid[i][j] && valid(i, j))
                return 1;
        }
    }
    return 0;
}

bool valid(int i, int j){
    if(grid[i][j]) return 0;
    if(lvalid(i,j)) return 1;
    if(rvalid(i,j)) return 1;
    if(uvalid(i,j)) return 1;
    if(dvalid(i,j)) return 1;

    if(ulvalid(i,j)) return 1;
    if(urvalid(i,j)) return 1;
    if(dlvalid(i,j)) return 1;
    return drvalid(i,j);
}

bool lvalid(int i, int j){
    bool flag=0;
    --j; int temp=1+(p&1);
    while(j>-1 && grid[i][j]==temp) {
        --j; flag=1;
    }
    return (flag && j>-1 && grid[i][j]==p);
}

bool rvalid(int i, int j){
    bool flag=0;
    ++j; int temp=1+(p&1);
    while(j<N && grid[i][j]==temp){
        ++j; flag=1;
    }
    return (flag  && j<N && grid[i][j]==p);
}

bool uvalid(int i, int j){
    bool flag=0;
    --i; int temp=1+(p&1);
    while(i>-1 && grid[i][j]==temp) {
        --i; flag=1;
    }
    return (flag && i>-1 && grid[i][j]==p);
}

bool dvalid(int i, int j){
    bool flag=0;
    ++i; int temp=1+(p&1);
    while(i<N && grid[i][j]==temp) {
        ++i; flag=1;
    }
    return (flag && i<N && grid[i][j]==p);
}

bool ulvalid(int i, int j){
    bool flag=0;
    --i; --j; int temp=1+(p&1);
    while(i>-1 && j>-1 && grid[i][j]==temp){
        --i; --j; flag=1;
    }
    return (flag && i>-1 && j>-1 && grid[i][j]==p);
}

bool urvalid(int i, int j){
    bool flag=0;
    --i; ++j; int temp=1+(p&1);
    while(i>-1 && j<N && grid[i][j]==temp){
        --i; ++j; flag=1;
    }
    return (flag && i>-1 && j<N && grid[i][j]==p);
}

bool dlvalid(int i, int j){
    bool flag=0;
    ++i; --j; int temp=1+(p&1);
    while(i<N && j>-1 && grid[i][j]==temp){
        ++i; --j; flag=1;
    }
    return (flag && i<N && j>-1 && grid[i][j]==p);
}

bool drvalid(int i, int j){
    bool flag=0;
    ++i; ++j; int temp=1+(p&1);
    while(i<N && j<N && grid[i][j]==temp){
        ++i; ++j; flag=1;
    }
    return (flag && i<N && j<N && grid[i][j]==p);
}

void makemove(){
    grid[x][y]=p;
    lmove() ; rmove() ; umove() ; dmove() ;
    ulmove(); urmove(); dlmove(); drmove();
}

void lmove(){
    int i=x, j=y;
    --j; int temp=1+(p&1);
    while(j>-1 && grid[i][j]==temp) --j;
    if(j>-1 && grid[i][j]==p){
        while(grid[i][++j]==temp)
            grid[i][j]=p;
    }
}
void rmove(){
    int i=x, j=y;
    ++j; int temp=1+(p&1);
    while(j<N && grid[i][j]==temp) ++j;
    if(j<N && grid[i][j]==p){
        while(grid[i][--j]==temp)
            grid[i][j]=p;
    }
}

void umove(){
    int i=x, j=y;
    --i; int temp=1+(p&1);
    while(i>-1 && grid[i][j]==temp) --i;
    if(i>-1 && grid[i][j]==p){
        while(grid[++i][j]==temp)
            grid[i][j]=p;
    }
}

void dmove(){
    int i=x, j=y;
    ++i; int temp=1+(p&1);
    while(i<N && grid[i][j]==temp) ++i;
    if(i<N && grid[i][j]==p){
        while(grid[--i][j]==temp)
            grid[i][j]=p;
    }
}

void ulmove(){
    int i=x, j=y;
    --i; --j; int temp=1+(p&1);
    while(i>-1 && j>-1 && grid[i][j]==temp){
        --i; --j;
    }
    if (i>-1 && j>-1 && grid[i][j]==p){
        while(grid[++i][++j]==temp)
            grid[i][j]=p;
    }
}

void urmove(){
    int i=x, j=y;
    --i; ++j; int temp=1+(p&1);
    while(i>-1 && j<N && grid[i][j]==temp){
        --i; ++j;
    }
    if (i>-1 && j<N && grid[i][j]==p){
        while(grid[++i][--j]==temp)
            grid[i][j]=p;
    }
}

void dlmove(){
    int i=x, j=y;
    ++i; --j; int temp=1+(p&1);
    while(i<N && j>-1 && grid[i][j]==temp){
        ++i; --j;
    }
    if (i<N && j>-1 && grid[i][j]==p){
        while(grid[--i][++j]==temp)
            grid[i][j]=p;
    }
}

void drmove(){
    int i=x, j=y;
    ++i; ++j; int temp=1+(p&1);
    while(i<N && j<N && grid[i][j]==temp){
        ++i; ++j;
    }
    if (i<N && j<N && grid[i][j]==p){
        while(grid[--i][--j]==temp)
            grid[i][j]=p;
    }
}

int winner(){
    int p1=0, p2=0;
    rep(i,N){
        rep(j,N){
            if(grid[i][j]==1) ++p1;
            if(grid[i][j]==2) ++p2; 
        }
    }
    std::cout<<"Score:"<<p1<<"-"<<p2<<'\n';
    return (p1==p2)?0:(p1>p2?1:2);
}
