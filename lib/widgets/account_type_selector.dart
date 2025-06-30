import 'package:flutter/material.dart';

/// شاشة اختيار نوع الحساب
/// تستخدم أثناء عملية التسجيل للسماح للمستخدم باختيار نوع الحساب
/// (مستثمر أو صاحب مشروع)
class AccountTypeSelector extends StatefulWidget {
  final Function(String) onAccountTypeSelected;
  final String initialAccountType;

  const AccountTypeSelector({
    super.key,
    required this.onAccountTypeSelected,
    this.initialAccountType = 'investor',
  });

  @override
  State<AccountTypeSelector> createState() => _AccountTypeSelectorState();
}

class _AccountTypeSelectorState extends State<AccountTypeSelector> {
  late String _selectedAccountType;

  @override
  void initState() {
    super.initState();
    _selectedAccountType = widget.initialAccountType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'اختر نوع الحساب',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildAccountTypeOption(
                title: 'مستثمر',
                subtitle: 'ابحث عن مشاريع للاستثمار فيها',
                value: 'investor',
                icon: Icons.account_balance_wallet,
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              _buildAccountTypeOption(
                title: 'صاحب مشروع',
                subtitle: 'أنشئ مشاريع وابحث عن مستثمرين',
                value: 'project_owner',
                icon: Icons.business,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedAccountType == value;

    return Semantics(
      selected: isSelected,
      button: true,
      label: title,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAccountType = value;
          });
          widget.onAccountTypeSelected(value);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: _selectedAccountType,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedAccountType = newValue;
                    });
                    widget.onAccountTypeSelected(newValue);
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
