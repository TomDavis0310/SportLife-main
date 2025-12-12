<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NewsResource\Pages;
use App\Models\News;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class NewsResource extends Resource
{
    protected static ?string $model = News::class;

    protected static ?string $navigationIcon = 'heroicon-o-newspaper';

    protected static ?string $navigationGroup = 'Nhà báo';

    protected static ?string $modelLabel = 'Tin tức';

    protected static ?int $navigationSort = 2;

    // Hiển thị cho Admin và Journalist
    public static function canAccess(): bool
    {
        $user = auth()->user();
        return $user && ($user->hasRole(['admin', 'journalist']) || $user->hasPermissionTo('news.view'));
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết bài viết')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Tiêu đề')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Select::make('category')
                            ->label('Danh mục')
                            ->options([
                                'match_report' => 'Báo cáo trận đấu',
                                'transfer' => 'Tin chuyển nhượng',
                                'injury' => 'Cập nhật chấn thương',
                                'preview' => 'Nhận định trận đấu',
                                'analysis' => 'Phân tích',
                                'general' => 'Chung',
                            ])
                            ->required(),
                        Forms\Components\Select::make('team_id')
                            ->label('Đội bóng')
                            ->relationship('team', 'name')
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('match_id')
                            ->label('Trận đấu')
                            ->relationship('match', 'id')
                            ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->homeTeam->name} vs {$record->awayTeam->name}")
                            ->searchable()
                            ->preload(),
                    ])->columns(2),

                Forms\Components\Section::make('Nội dung')
                    ->schema([
                        Forms\Components\Textarea::make('excerpt')
                            ->label('Tóm tắt')
                            ->required()
                            ->maxLength(500),
                        Forms\Components\RichEditor::make('content')
                            ->label('Nội dung chi tiết')
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Forms\Components\Section::make('Đa phương tiện')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->label('Hình ảnh')
                            ->image()
                            ->directory('news'),
                        Forms\Components\TextInput::make('video_url')
                            ->url()
                            ->label('Video URL (YouTube/Vimeo)'),
                    ])->columns(2),

                Forms\Components\Section::make('Xuất bản')
                    ->schema([
                        Forms\Components\Toggle::make('is_featured')
                            ->label('Nổi bật')
                            ->default(false),
                        Forms\Components\Toggle::make('is_published')
                            ->label('Đã xuất bản')
                            ->default(true),
                        Forms\Components\DateTimePicker::make('published_at')
                            ->label('Ngày xuất bản')
                            ->default(now()),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Hình ảnh')
                    ->square(),
                Tables\Columns\TextColumn::make('title')
                    ->label('Tiêu đề')
                    ->searchable()
                    ->sortable()
                    ->limit(50),
                Tables\Columns\TextColumn::make('category')
                    ->label('Danh mục')
                    ->badge(),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Đội bóng'),
                Tables\Columns\TextColumn::make('views')
                    ->label('Lượt xem')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Nổi bật')
                    ->boolean(),
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Đã xuất bản')
                    ->boolean(),
                Tables\Columns\TextColumn::make('published_at')
                    ->label('Ngày xuất bản')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('source_name')
                    ->label('Nguồn')
                    ->badge()
                    ->color('info')
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\IconColumn::make('is_auto_fetched')
                    ->label('Tự động')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('published_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->label('Danh mục')
                    ->options([
                        'match_report' => 'Báo cáo trận đấu',
                        'transfer' => 'Tin chuyển nhượng',
                        'injury' => 'Cập nhật chấn thương',
                        'preview' => 'Nhận định trận đấu',
                        'analysis' => 'Phân tích',
                        'general' => 'Chung',
                    ]),
                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('Nổi bật'),
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('Đã xuất bản'),
                Tables\Filters\TernaryFilter::make('is_auto_fetched')
                    ->label('Tin tự động'),
                Tables\Filters\SelectFilter::make('source_name')
                    ->label('Nguồn tin')
                    ->options([
                        'VnExpress' => 'VnExpress',
                        'Thanh Niên' => 'Thanh Niên',
                        'Tuổi Trẻ' => 'Tuổi Trẻ',
                        'Bóng Đá Plus' => 'Bóng Đá Plus',
                        'Bongda24h' => 'Bongda24h',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNews::route('/'),
            'create' => Pages\CreateNews::route('/create'),
            'edit' => Pages\EditNews::route('/{record}/edit'),
        ];
    }
}
