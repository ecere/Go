#ifdef ECERE_STATIC
import static "ecere"
#else
import "ecere"
#endif

define margin = 40;
define goSize = 19;
define tileSize = 32;

enum DotState : byte
{
   empty,
   black,
   white,
   invalid
};

DotState board[goSize][goSize];

bool placing;
DotState playerColor = white;
Point piecePos;

class GoWindow : Window
{
   caption = $"Game of Go";

#ifdef __EMSCRIPTEN__
   anchor = { 0, 0, 0, 0 };
#else
   borderStyle = sizable;
   hasMaximize = true;
   hasMinimize = true;
   hasClose = true;
   clientSize = { 624, 624 };
#endif
   void drawPiece(Surface surface, int x, int y, DotState state)
   {
      int sx = margin + tileSize * x;
      int sy = margin + tileSize * y;
      surface.background = state == white ? white : state == black ? black : red;
      surface.foreground = gray;
      surface.Area(sx - 8, sy - 8,
         sx + 8,
         sy + 8);
      surface.Rectangle(sx - 8, sy - 8,
         sx + 8,
         sy + 8);
   }

   void OnRedraw(Surface surface)
   {
      int i;
      int x, y;
      /*surface.Rectangle(margin, margin,
         margin + tileSize * (goSize-1),
         margin + tileSize * (goSize-1));
      */
      for(i = 0; i < goSize-1; i++)
      {
         surface.HLine(margin,
            margin + tileSize * (goSize-2),
            i * tileSize + margin);
         surface.VLine(margin,
            margin + tileSize * (goSize-2),
            i * tileSize + margin);
      }

      for(y = 0; y < goSize; y++)
         for(x = 0; x < goSize; x++)
         {
            DotState state = board[y][x];
            if(state)
               drawPiece(surface, x, y, state);
         }

      if(placing)
      {
         drawPiece(surface, piecePos.x, piecePos.y,
            board[piecePos.y][piecePos.x] == empty ? playerColor : invalid);

      }
   }

   bool OnLeftButtonDown(int x, int y, Modifiers mods)
   {
      Point pos
      {
         (x - margin + tileSize/2) / tileSize,
         (y - margin + tileSize/2) / tileSize
      };
      if(pos.x >= 0 && pos.x < goSize && pos.y >= 0 && pos.y < goSize)
      {
         piecePos = pos;
         placing = true;
         Capture();
         Update(null);
      }
      return true;
   }

   bool OnMouseMove(int x, int y, Modifiers mods)
   {
      if(placing)
      {
         Point pos
         {
            (x - margin + tileSize/2) / tileSize,
            (y - margin + tileSize/2) / tileSize
         };
         if(pos.x >= 0 && pos.x < goSize-1 && pos.y >= 0 && pos.y < goSize-1)
         {
            piecePos = pos;
            Update(null);
         }
      }
      return true;
   }

   bool OnLeftButtonUp(int x, int y, Modifiers mods)
   {
      if(placing)
      {
         Point pos
         {
            (x - margin + tileSize/2) / tileSize,
            (y - margin + tileSize/2) / tileSize
         };
         if(pos.x >= 0 && pos.x < goSize-1 && pos.y >= 0 && pos.y < goSize-1)
         {
            movePlayed(pos.x, pos.y);
         }
         placing = false;
         ReleaseCapture();
         Update(null);
      }
      return true;
   }

   void checkSurrounded(int x, int y)
   {
      if(x >= 1 && y >= 1 && x < goSize-1 && y < goSize-1)
      {
         if(board[y-1][x] == playerColor &&
            board[y+1][x] == playerColor &&
            board[y][x-1] == playerColor &&
            board[y][x+1] == playerColor)
         {
            board[y][x] = empty;
         }
      }
   }

   bool movePlayed(int x, int y)
   {
      if(board[y][x] == empty)
      {
         board[y][x] = playerColor;
         checkSurrounded(x, y - 1);
         checkSurrounded(x, y + 1);
         checkSurrounded(x - 1, y);
         checkSurrounded(x + 1, y);
         playerColor = playerColor == white ? black : white;
         return true;
      }
      return false;
   }
}

GoWindow goWindow {};
