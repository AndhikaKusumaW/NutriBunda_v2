# NutriBunda Accessibility Guide

## Overview

This document describes the accessibility features implemented in NutriBunda to ensure the app is usable by all users, including those with disabilities.

**Task 19.1 Implementation**: UI/UX refinement and accessibility improvements

## Accessibility Features

### 1. Screen Reader Support

All interactive elements in the app have proper semantic labels for screen readers (TalkBack on Android, VoiceOver on iOS).

#### Implementation

- **Semantic Widgets**: All buttons, cards, and interactive elements are wrapped with `Semantics` widgets
- **Accessibility Helper**: Utility class (`AccessibilityHelper`) provides consistent semantic labels
- **Navigation**: Bottom navigation bar has proper labels indicating current tab and total tabs
- **Content Description**: Images, icons, and decorative elements have appropriate descriptions

#### Examples

```dart
// Button with semantic label
AccessibilityHelper.accessibleIconButton(
  icon: Icons.add,
  label: 'Tambah makanan',
  hint: 'Ketuk dua kali untuk menambah entri makanan',
  onPressed: () => _addEntry(),
);

// Navigation tab with semantic label
Semantics(
  label: AccessibilityHelper.navigationTabLabel(
    tabName: 'Home',
    index: 0,
    total: 4,
    isSelected: true,
  ),
  child: Icon(Icons.home),
);
```

### 2. Color Contrast

All text and interactive elements meet WCAG AA standards for color contrast (minimum 4.5:1 for normal text, 3:1 for large text).

#### Color Palette

- **Primary Green**: `#4CAF50` - Used for primary actions and branding
- **Text Primary**: `#212121` - High contrast for body text
- **Text Secondary**: `#757575` - Medium contrast for secondary text
- **Error Red**: `#D32F2F` - High contrast for error states
- **Success Green**: `#388E3C` - High contrast for success states

#### Semantic Colors

- **Baby Profile**: Blue (`#2196F3`)
- **Mother Profile**: Pink (`#E91E63`)
- **Warning**: Orange (`#F57C00`)
- **Info**: Blue (`#1976D2`)

### 3. Touch Target Sizes

All interactive elements meet the minimum touch target size of 48x48 dp as recommended by Material Design guidelines.

#### Implementation

- Buttons: Minimum 48dp height with adequate padding
- Icon buttons: 48x48 dp touch area
- List items: Minimum 48dp height
- Bottom navigation items: 56dp height

### 4. Focus Management

Proper focus order and keyboard navigation support for users who navigate using external keyboards or assistive devices.

#### Features

- Logical tab order through forms and interactive elements
- Visible focus indicators
- Focus restoration when returning to screens
- Skip navigation for repetitive content

### 5. Text Scaling

The app supports system text scaling settings (up to 200%) without breaking layouts.

#### Implementation

- Relative text sizes using `TextTheme`
- Flexible layouts that adapt to text size changes
- No hardcoded pixel values for text
- Proper text overflow handling

### 6. Semantic Labels

Comprehensive semantic labels for all UI elements to provide context for screen reader users.

#### Categories

**Nutrition Values**
```dart
AccessibilityHelper.nutritionValueLabel(
  nutrientName: 'Kalori',
  current: 500,
  target: 2000,
  unit: 'kalori',
);
// Output: "Kalori: 500 dari 2000 kalori, 25 persen"
```

**Dates**
```dart
AccessibilityHelper.dateLabel(DateTime.now());
// Output: "Tanggal dipilih: Senin, 15 Januari 2024"
```

**Food Entries**
```dart
AccessibilityHelper.foodEntryLabel(
  foodName: 'Nasi Putih',
  servingSize: 100,
  mealTime: 'breakfast',
  calories: 130,
);
// Output: "Nasi Putih, 100 gram, Makan Pagi, 130 kalori"
```

**Progress Indicators**
```dart
AccessibilityHelper.progressLabel(
  item: 'Kalori harian',
  current: 1500,
  total: 2000,
);
// Output: "Kalori harian: 75 persen selesai"
```

### 7. Announcements

Important state changes and user actions are announced to screen readers.

#### Usage

```dart
// Announce success message
AccessibilityHelper.announce(
  context,
  'Makanan berhasil ditambahkan',
);

// Announce error
AccessibilityHelper.announce(
  context,
  'Gagal menyimpan data, silakan coba lagi',
);
```

### 8. Image Descriptions

All images have semantic labels describing their content.

#### Implementation

```dart
AccessibilityHelper.accessibleImage(
  image: AssetImage('assets/images/food.jpg'),
  label: 'Foto makanan: Nasi goreng dengan telur',
  width: 200,
  height: 150,
);
```

### 9. Form Accessibility

Forms have proper labels, hints, and error messages for screen readers.

#### Features

- Input fields have descriptive labels
- Error messages are announced
- Required fields are indicated
- Validation feedback is accessible

### 10. Loading States

Loading indicators have semantic labels to inform users about ongoing operations.

```dart
Semantics(
  label: AccessibilityHelper.loadingLabel('data nutrisi'),
  child: CircularProgressIndicator(),
);
```

## Testing Accessibility

### Android (TalkBack)

1. Enable TalkBack: Settings > Accessibility > TalkBack
2. Navigate using swipe gestures
3. Verify all elements are announced correctly
4. Test all interactive elements

### iOS (VoiceOver)

1. Enable VoiceOver: Settings > Accessibility > VoiceOver
2. Navigate using swipe gestures
3. Verify all elements are announced correctly
4. Test all interactive elements

### Manual Testing Checklist

- [ ] All buttons have descriptive labels
- [ ] Navigation is logical and sequential
- [ ] Images have alternative text
- [ ] Color is not the only means of conveying information
- [ ] Text is readable at 200% zoom
- [ ] Touch targets are at least 48x48 dp
- [ ] Error messages are clear and announced
- [ ] Loading states are announced
- [ ] Success/failure feedback is provided

## Accessibility Helper API

### Navigation Labels

```dart
// Tab navigation
AccessibilityHelper.navigationTabLabel(
  tabName: 'Home',
  index: 0,
  total: 4,
  isSelected: true,
);

// List items
AccessibilityHelper.listItemLabel(
  itemName: 'Nasi Putih',
  index: 0,
  total: 10,
);
```

### Nutrition Labels

```dart
// Nutrition values
AccessibilityHelper.nutritionValueLabel(
  nutrientName: 'Protein',
  current: 50,
  target: 60,
  unit: 'gram',
);

// Metabolic rates
AccessibilityHelper.metabolicRateLabel(
  type: 'BMR',
  value: 1500,
);
```

### Action Labels

```dart
// Icon buttons
AccessibilityHelper.iconButtonLabel(
  'Hapus',
  context: 'entri makanan',
);

// Interaction hints
AccessibilityHelper.getInteractionHint('menambah makanan');
```

### State Labels

```dart
// Loading
AccessibilityHelper.loadingLabel('data profil');

// Error
AccessibilityHelper.errorLabel('data nutrisi', 'koneksi terputus');

// Empty state
AccessibilityHelper.emptyStateLabel('catatan makanan');
```

## Best Practices

### DO

✅ Use semantic widgets for all interactive elements
✅ Provide descriptive labels for buttons and links
✅ Use sufficient color contrast (WCAG AA minimum)
✅ Make touch targets at least 48x48 dp
✅ Support text scaling up to 200%
✅ Announce important state changes
✅ Provide alternative text for images
✅ Use logical focus order
✅ Test with screen readers regularly

### DON'T

❌ Rely on color alone to convey information
❌ Use images of text instead of actual text
❌ Create touch targets smaller than 48x48 dp
❌ Use low contrast colors for text
❌ Hardcode text sizes in pixels
❌ Ignore screen reader announcements
❌ Use decorative images without excluding from semantics
❌ Create complex gestures as the only interaction method

## Resources

- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)
- [iOS Accessibility](https://developer.apple.com/accessibility/)

## Future Improvements

- [ ] Add support for high contrast mode
- [ ] Implement custom accessibility actions
- [ ] Add voice control support
- [ ] Improve keyboard navigation
- [ ] Add accessibility settings page
- [ ] Implement haptic feedback for important actions
- [ ] Add sound effects for state changes
- [ ] Support for reduced motion preferences

## Contact

For accessibility issues or suggestions, please contact the development team or file an issue in the project repository.
