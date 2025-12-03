<?php

namespace Database\Seeders;

use App\Models\Team;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class TeamSeeder extends Seeder
{
    public function run(): void
    {
        // Premier League Teams
        $premierLeagueTeams = [
            ['name' => 'Manchester City', 'short_name' => 'MCI', 'country' => 'England', 'city' => 'Manchester', 'stadium' => 'Etihad Stadium', 'founded_year' => 1880, 'primary_color' => '#6CABDD', 'secondary_color' => '#1C2C5B'],
            ['name' => 'Arsenal', 'short_name' => 'ARS', 'country' => 'England', 'city' => 'London', 'stadium' => 'Emirates Stadium', 'founded_year' => 1886, 'primary_color' => '#EF0107', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Liverpool', 'short_name' => 'LIV', 'country' => 'England', 'city' => 'Liverpool', 'stadium' => 'Anfield', 'founded_year' => 1892, 'primary_color' => '#C8102E', 'secondary_color' => '#00B2A9'],
            ['name' => 'Chelsea', 'short_name' => 'CHE', 'country' => 'England', 'city' => 'London', 'stadium' => 'Stamford Bridge', 'founded_year' => 1905, 'primary_color' => '#034694', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Manchester United', 'short_name' => 'MUN', 'country' => 'England', 'city' => 'Manchester', 'stadium' => 'Old Trafford', 'founded_year' => 1878, 'primary_color' => '#DA291C', 'secondary_color' => '#FBE122'],
            ['name' => 'Tottenham Hotspur', 'short_name' => 'TOT', 'country' => 'England', 'city' => 'London', 'stadium' => 'Tottenham Hotspur Stadium', 'founded_year' => 1882, 'primary_color' => '#132257', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Newcastle United', 'short_name' => 'NEW', 'country' => 'England', 'city' => 'Newcastle', 'stadium' => "St James' Park", 'founded_year' => 1892, 'primary_color' => '#241F20', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Aston Villa', 'short_name' => 'AVL', 'country' => 'England', 'city' => 'Birmingham', 'stadium' => 'Villa Park', 'founded_year' => 1874, 'primary_color' => '#670E36', 'secondary_color' => '#95BFE5'],
            ['name' => 'Brighton', 'short_name' => 'BHA', 'country' => 'England', 'city' => 'Brighton', 'stadium' => 'Amex Stadium', 'founded_year' => 1901, 'primary_color' => '#0057B8', 'secondary_color' => '#FFFFFF'],
            ['name' => 'West Ham United', 'short_name' => 'WHU', 'country' => 'England', 'city' => 'London', 'stadium' => 'London Stadium', 'founded_year' => 1895, 'primary_color' => '#7A263A', 'secondary_color' => '#1BB1E7'],
            ['name' => 'Brentford', 'short_name' => 'BRE', 'country' => 'England', 'city' => 'London', 'stadium' => 'Gtech Community Stadium', 'founded_year' => 1889, 'primary_color' => '#E30613', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Crystal Palace', 'short_name' => 'CRY', 'country' => 'England', 'city' => 'London', 'stadium' => 'Selhurst Park', 'founded_year' => 1905, 'primary_color' => '#1B458F', 'secondary_color' => '#C4122E'],
            ['name' => 'Wolverhampton', 'short_name' => 'WOL', 'country' => 'England', 'city' => 'Wolverhampton', 'stadium' => 'Molineux Stadium', 'founded_year' => 1877, 'primary_color' => '#FDB913', 'secondary_color' => '#231F20'],
            ['name' => 'Fulham', 'short_name' => 'FUL', 'country' => 'England', 'city' => 'London', 'stadium' => 'Craven Cottage', 'founded_year' => 1879, 'primary_color' => '#FFFFFF', 'secondary_color' => '#000000'],
            ['name' => 'Bournemouth', 'short_name' => 'BOU', 'country' => 'England', 'city' => 'Bournemouth', 'stadium' => 'Vitality Stadium', 'founded_year' => 1899, 'primary_color' => '#DA291C', 'secondary_color' => '#000000'],
            ['name' => 'Nottingham Forest', 'short_name' => 'NFO', 'country' => 'England', 'city' => 'Nottingham', 'stadium' => 'City Ground', 'founded_year' => 1865, 'primary_color' => '#DD0000', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Everton', 'short_name' => 'EVE', 'country' => 'England', 'city' => 'Liverpool', 'stadium' => 'Goodison Park', 'founded_year' => 1878, 'primary_color' => '#003399', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Leicester City', 'short_name' => 'LEI', 'country' => 'England', 'city' => 'Leicester', 'stadium' => 'King Power Stadium', 'founded_year' => 1884, 'primary_color' => '#003090', 'secondary_color' => '#FDBE11'],
            ['name' => 'Ipswich Town', 'short_name' => 'IPS', 'country' => 'England', 'city' => 'Ipswich', 'stadium' => 'Portman Road', 'founded_year' => 1878, 'primary_color' => '#0033A0', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Southampton', 'short_name' => 'SOU', 'country' => 'England', 'city' => 'Southampton', 'stadium' => "St Mary's Stadium", 'founded_year' => 1885, 'primary_color' => '#D71920', 'secondary_color' => '#FFFFFF'],
        ];

        // Vietnamese V.League Teams
        $vleagueTeams = [
            ['name' => 'Công An Hà Nội', 'short_name' => 'CAHN', 'country' => 'Vietnam', 'city' => 'Hà Nội', 'stadium' => 'Sân vận động Hàng Đẫy', 'founded_year' => 1956, 'primary_color' => '#FFD700', 'secondary_color' => '#FF0000'],
            ['name' => 'Hà Nội FC', 'short_name' => 'HN', 'country' => 'Vietnam', 'city' => 'Hà Nội', 'stadium' => 'Sân vận động Hàng Đẫy', 'founded_year' => 2006, 'primary_color' => '#800000', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Becamex Bình Dương', 'short_name' => 'BD', 'country' => 'Vietnam', 'city' => 'Bình Dương', 'stadium' => 'Sân vận động Gò Đậu', 'founded_year' => 1976, 'primary_color' => '#0000FF', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Hoàng Anh Gia Lai', 'short_name' => 'HAGL', 'country' => 'Vietnam', 'city' => 'Pleiku', 'stadium' => 'Sân vận động Pleiku', 'founded_year' => 2001, 'primary_color' => '#FFD700', 'secondary_color' => '#008000'],
            ['name' => 'Sông Lam Nghệ An', 'short_name' => 'SLNA', 'country' => 'Vietnam', 'city' => 'Vinh', 'stadium' => 'Sân vận động Vinh', 'founded_year' => 1979, 'primary_color' => '#FFD700', 'secondary_color' => '#000000'],
            ['name' => 'Thể Công Viettel', 'short_name' => 'VTL', 'country' => 'Vietnam', 'city' => 'Hà Nội', 'stadium' => 'Sân vận động Hàng Đẫy', 'founded_year' => 1954, 'primary_color' => '#FF0000', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Hải Phòng', 'short_name' => 'HP', 'country' => 'Vietnam', 'city' => 'Hải Phòng', 'stadium' => 'Sân vận động Lạch Tray', 'founded_year' => 1952, 'primary_color' => '#FF0000', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Nam Định', 'short_name' => 'ND', 'country' => 'Vietnam', 'city' => 'Nam Định', 'stadium' => 'Sân vận động Thiên Trường', 'founded_year' => 1965, 'primary_color' => '#FFD700', 'secondary_color' => '#000000'],
            ['name' => 'Thanh Hóa', 'short_name' => 'TH', 'country' => 'Vietnam', 'city' => 'Thanh Hóa', 'stadium' => 'Sân vận động Thanh Hóa', 'founded_year' => 1962, 'primary_color' => '#0000FF', 'secondary_color' => '#FF0000'],
            ['name' => 'Đông Á Thanh Hóa', 'short_name' => 'DATH', 'country' => 'Vietnam', 'city' => 'Thanh Hóa', 'stadium' => 'Sân vận động Thanh Hóa', 'founded_year' => 1962, 'primary_color' => '#0000FF', 'secondary_color' => '#FFFFFF'],
            ['name' => 'SHB Đà Nẵng', 'short_name' => 'DN', 'country' => 'Vietnam', 'city' => 'Đà Nẵng', 'stadium' => 'Sân vận động Hòa Xuân', 'founded_year' => 1976, 'primary_color' => '#FF8C00', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Khánh Hòa', 'short_name' => 'KH', 'country' => 'Vietnam', 'city' => 'Nha Trang', 'stadium' => 'Sân vận động 19-8', 'founded_year' => 1976, 'primary_color' => '#0000FF', 'secondary_color' => '#FFFFFF'],
            ['name' => 'TP. Hồ Chí Minh', 'short_name' => 'HCM', 'country' => 'Vietnam', 'city' => 'TP. Hồ Chí Minh', 'stadium' => 'Sân vận động Thống Nhất', 'founded_year' => 1975, 'primary_color' => '#FF0000', 'secondary_color' => '#FFFFFF'],
            ['name' => 'Bình Định', 'short_name' => 'BĐ', 'country' => 'Vietnam', 'city' => 'Quy Nhơn', 'stadium' => 'Sân vận động Quy Nhơn', 'founded_year' => 1976, 'primary_color' => '#FFD700', 'secondary_color' => '#FF0000'],
        ];

        foreach (array_merge($premierLeagueTeams, $vleagueTeams) as $teamData) {
            $teamData['logo'] = 'teams/' . Str::slug($teamData['name']) . '.png';

            Team::updateOrCreate(
                ['short_name' => $teamData['short_name']],
                $teamData
            );
        }
    }
}
