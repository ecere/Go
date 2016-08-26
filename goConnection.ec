import "go"

GoConnection playerConnections[2];
DotState playerColor = white;
int numPlayers;

remote class GoConnection
{
   void join()
   {
      if(numPlayers < 2)
         playerConnections[numPlayers++] = this;
   }

   void playMove(int color, int x, int y)
   {
      if(numPlayers == 2 && color == playerColor)
      {
         playerConnections[0].notifyMovePlayed(color, x, y);
         playerConnections[1].notifyMovePlayed(color, x, y);

         playerColor = playerColor == white ? black : white;
      }
   }

   virtual void notifyMovePlayed(int color, int x, int y);
};

define goPort = 1489;
DCOMService goService { port = goPort };
