<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RewardResource\Pages;
use App\Models\Reward;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class RewardResource extends Resource
{
    protected static ?string $model = Reward::class;

    protected static ?string $navigationIcon = 'heroicon-o-gift';

    protected static ?string $navigationGroup = 'Tài trợ & Đổi thưởng';

    protected static ?string $modelLabel = 'Phần thưởng';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết phần thưởng')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên phần thưởng')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Select::make('type')
                            ->label('Loại')
                            ->options([
                                'subscription' => 'Gói đăng ký',
                                'voucher' => 'Voucher',
                                'merchandise' => 'Vật phẩm',
                                'experience' => 'Trải nghiệm',
                            ])
                            ->required(),
                        Forms\Components\Select::make('sponsor_id')
                            ->label('Nhà tài trợ')
                            ->relationship('sponsor', 'name')
                            ->searchable()
                            ->preload(),
                        Forms\Components\Textarea::make('description')
                            ->label('Mô tả')
                            ->required()
                            ->maxLength(1000),
                    ])->columns(2),

                Forms\Components\Section::make('Giá & Kho')
                    ->schema([
                        Forms\Components\TextInput::make('points_required')
                            ->label('Điểm yêu cầu')
                            ->required()
                            ->numeric()
                            ->minValue(1),
                        Forms\Components\TextInput::make('stock')
                            ->label('Số lượng tồn kho')
                            ->required()
                            ->numeric()
                            ->minValue(0),
                        Forms\Components\DatePicker::make('valid_until')
                            ->label('Hạn sử dụng'),
                        Forms\Components\Toggle::make('is_physical')
                            ->label('Vật phẩm vật lý (cần giao hàng)'),
                    ])->columns(2),

                Forms\Components\Section::make('Hình ảnh')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->label('Hình ảnh')
                            ->image()
                            ->directory('rewards'),
                    ]),

                Forms\Components\Section::make('Trạng thái')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Kích hoạt')
                            ->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Hình ảnh')
                    ->square(),
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên phần thưởng')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('Loại')
                    ->badge(),
                Tables\Columns\TextColumn::make('sponsor.name')
                    ->label('Nhà tài trợ'),
                Tables\Columns\TextColumn::make('points_required')
                    ->label('Điểm')
                    ->sortable()
                    ->badge()
                    ->color('success'),
                Tables\Columns\TextColumn::make('stock')
                    ->label('Tồn kho')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Kích hoạt')
                    ->boolean(),
                Tables\Columns\TextColumn::make('valid_until')
                    ->label('Hạn sử dụng')
                    ->date(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Loại')
                    ->options([
                        'subscription' => 'Gói đăng ký',
                        'voucher' => 'Voucher',
                        'merchandise' => 'Vật phẩm',
                        'experience' => 'Trải nghiệm',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Kích hoạt'),
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
            'index' => Pages\ListRewards::route('/'),
            'create' => Pages\CreateReward::route('/create'),
            'edit' => Pages\EditReward::route('/{record}/edit'),
        ];
    }
}
