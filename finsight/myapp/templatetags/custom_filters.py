from django import template

register = template.Library()

@register.filter
def filter_by_recommendation(data, recommendation):
    return [item for item in data if item.get('Recommendation') == recommendation]